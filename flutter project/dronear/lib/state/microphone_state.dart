import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/microphone_service.dart';
import 'package:fftea/fftea.dart';
import '../utils/logger.dart';

// ===================
// WORKER ISOLATE CODE
// ===================

// Message types for worker communication
class PcmDataMessage {
  final List<int> pcmBytes;
  PcmDataMessage(this.pcmBytes);
}

class StopMessage {}

class SpectrogramFrameMessage {
  final List<double> frame;
  SpectrogramFrameMessage(this.frame);
}

// Worker entry point
void spectrogramWorker(SendPort mainSendPort) async {
  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort);

  const int nFft = 1024;
  const int hopLength = 512;
  const double fullScale = 32768.0;
  final List<double> pcmBuffer = [];
  int unprocessedStart = 0;

  await for (final message in workerReceivePort) {
    if (message is PcmDataMessage) {
      final bytes = message.pcmBytes;
      for (int i = 0; i < bytes.length - 1; i += 2) {
        int sample = bytes[i] | (bytes[i + 1] << 8);
        if (sample >= 0x8000) sample -= 0x10000;
        pcmBuffer.add(sample.toDouble());
      }
      while (unprocessedStart + nFft <= pcmBuffer.length) {
        final window = pcmBuffer.sublist(unprocessedStart, unprocessedStart + nFft);
        final windowed = List<double>.generate(
          nFft,
          (i) => window[i] * (0.5 - 0.5 * cos(2 * pi * i / (nFft - 1))),
        );
        final fft = FFT(nFft);
        final spectrum = fft.realFft(windowed);
        final row = List<double>.generate(nFft ~/ 2, (i) {
          final re = spectrum[i].x;
          final im = spectrum[i].y;
          final mag = sqrt(re * re + im * im);
          return 20 * log(mag / (nFft * fullScale) + 1e-10) / ln10;
        });
        mainSendPort.send(SpectrogramFrameMessage(row));
        unprocessedStart += hopLength;
      }
      // Limit buffer size for safety (keep 10 seconds)
      const int maxPcmBuffer = 48000 * 10;
      if (pcmBuffer.length > maxPcmBuffer) {
        int removeCount = pcmBuffer.length - maxPcmBuffer;
        pcmBuffer.removeRange(0, removeCount);
        unprocessedStart -= removeCount;
        if (unprocessedStart < 0) unprocessedStart = 0;
      }
    } else if (message is StopMessage) {
      break;
    }
  }
  workerReceivePort.close();
}

// ===================
// MAIN STATE CODE
// ===================

class MicrophoneState extends ChangeNotifier {
  final MicrophoneService _microphoneService = MicrophoneService();

  bool _isRecording = false;
  double _lastVolume = -100.0;

  // Config
  final int sampleRate = 48000;
  final int nFft = 1024;
  final int hopLength = 512;
  final int spectrogramDurationSec = 5;

  final List<List<double>> _spectrogram = [];
  List<double> _currentFrequencySpectrum = [];

  // === Bitmap/Cyclic Uint8List for the rolling spectrogram ===
  // Each frame is a vertical strip. This buffer is always width*height*4 (RGBA).
  final int bitmapHeight = 1024 ~/ 2; // nFft ~/ 2
  late final int bitmapWidth = ((sampleRate * spectrogramDurationSec - nFft) ~/ hopLength) + 1;
  late final Uint8List _spectrogramBitmap = Uint8List(bitmapWidth * bitmapHeight * 4);
  int _bitmapWriteX = 0; // Current column (frame) to write to, rolling

  // === END Bitmap additions ===

  int get _maxFrames => bitmapWidth;

  StreamSubscription<Uint8List>? _pcmSubscription;

  // Isolate comms
  Isolate? _workerIsolate;
  SendPort? _workerSendPort;
  ReceivePort? _mainReceivePort;

  Future<void> init() async {
    await _microphoneService.init();
  }

  Future<bool> requestPermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    if (!await requestPermission()) {
      throw Exception('Microphone permission not granted');
    }

    _spectrogram.clear();
    _currentFrequencySpectrum = [];
    _bitmapWriteX = 0;
    _spectrogramBitmap.fillRange(0, _spectrogramBitmap.length, 0);

    // Start worker isolate and set up comms
    _mainReceivePort = ReceivePort();
    _workerIsolate = await Isolate.spawn(spectrogramWorker, _mainReceivePort!.sendPort);

    // Only listen ONCE to the ReceivePort to avoid StateError
    _mainReceivePort!.listen((message) {
      if (_workerSendPort == null && message is SendPort) {
        _workerSendPort = message;
      } else if (message is SpectrogramFrameMessage) {
        _spectrogram.add(message.frame);
        if (_spectrogram.length > _maxFrames) {
          _spectrogram.removeRange(0, _spectrogram.length - _maxFrames);
        }
        _currentFrequencySpectrum = message.frame;

        // === Update rolling Uint8List bitmap ===
        _putSpectrogramFrameToBitmap(message.frame);
        // === End bitmap update ===

        notifyListeners();
      }
    });

    // Start microphone stream
    final stream = await _microphoneService.startRecording();
    if (stream != null) {
      _isRecording = true;
      notifyListeners();

      _pcmSubscription = stream.listen((data) {
        _lastVolume = _calculateVolumeDb(data);
        if (_workerSendPort != null) {
          _workerSendPort?.send(PcmDataMessage(data));
        }
      });
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _pcmSubscription?.cancel();
      await _microphoneService.stopRecording();
      _isRecording = false;
      _lastVolume = -100.0;
      _currentFrequencySpectrum = [];
      _workerSendPort?.send(StopMessage());
      _mainReceivePort?.close();
      _workerIsolate?.kill(priority: Isolate.immediate);
      _workerIsolate = null;
      _workerSendPort = null;
      _mainReceivePort = null;
      notifyListeners();
    }
  }

  double _calculateVolumeDb(Uint8List data) {
    if (data.isEmpty) return -100.0;
    double sum = 0.0;
    int sampleCount = data.length ~/ 2;
    for (int i = 0; i < data.length - 1; i += 2) {
      int sample = data[i] | (data[i + 1] << 8);
      if (sample >= 0x8000) sample -= 0x10000;
      sum += sample * sample;
    }
    double rms = sqrt(sum / sampleCount);
    double dbfs = 20 * log(rms / 32768.0 + 1e-10) / ln10;
    return dbfs.isFinite ? double.parse(dbfs.toStringAsFixed(2)) : -100.0;
  }

  /// Maps dB magnitude to color. You can improve this for a better palette.
  static int _colorForDb(double db) {
    // Map db (-80..0) to 0..255
    final norm = ((db + 80) / 80).clamp(0.0, 1.0);
    // Simple grayscale: (R=G=B=val)
    final v = (norm * 255).round();
    // Hot color map example: black -> red -> yellow -> white
    if (norm < 0.5) {
      return (255 << 24) | ((v * 2) << 16); // Red shades (opaque)
    } else {
      // Yellow to white
      int rv = 255;
      int gv = ((norm - 0.5) * 2 * 255).clamp(0, 255).toInt();
      return (255 << 24) | (rv << 16) | (gv << 8) | gv;
    }
  }

  /// Put a new frame into the rolling Uint8List bitmap at current X
  void _putSpectrogramFrameToBitmap(List<double> frame) {
    for (int y = 0; y < bitmapHeight; y++) {
      int color = _colorForDb(frame[y]);
      int pixelOffset = (y * bitmapWidth + _bitmapWriteX) * 4;
      _spectrogramBitmap[pixelOffset + 0] = (color >> 16) & 0xFF; // R
      _spectrogramBitmap[pixelOffset + 1] = (color >> 8) & 0xFF; // G
      _spectrogramBitmap[pixelOffset + 2] = color & 0xFF; // B
      _spectrogramBitmap[pixelOffset + 3] = (color >> 24) & 0xFF; // A
    }
    _bitmapWriteX = (_bitmapWriteX + 1) % bitmapWidth;
  }

  /// Returns the most recently computed frequency spectrum (magnitude in dB).
  List<double> getCurrentFrequencySpectrum() => _currentFrequencySpectrum;

  /// Returns the spectrogram (list of frames, each is a [dB] list).
  List<List<double>> getSpectrogram() => _spectrogram;

  /// Returns the RGBA byte buffer for the rolling bitmap spectrogram.
  /// The buffer is cyclic, so consumers should handle wrap-around for scrolling.
  Uint8List getSpectrogramBitmap() => _spectrogramBitmap;
  int getSpectrogramBitmapWriteX() => _bitmapWriteX;
  int getSpectrogramBitmapWidth() => bitmapWidth;
  int getSpectrogramBitmapHeight() => bitmapHeight;

  // Accessors
  double get getVolume => _lastVolume;
  bool get isRecording => _isRecording;
}
