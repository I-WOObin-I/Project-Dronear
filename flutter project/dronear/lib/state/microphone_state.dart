import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/microphone_service.dart';
import '../utils/logger.dart';
import '../utils/spectrogram_worker.dart';
import 'spectrogram_bitmap_state.dart';
import 'recogniser_state.dart';

class MicrophoneState extends ChangeNotifier {
  final MicrophoneService _microphoneService = MicrophoneService();

  bool _isRecording = false;
  double _lastVolume = -100.0;

  // Config
  final int sampleRate = 48000;
  final int nFft = 8192;
  final int hopLength = 1024;
  final int spectrogramDurationSec = 2;
  final int targetFrameHeight = 4096;
  late final int targetFrameWidth = 32;

  final List<List<double>> _spectrogram = [];

  // Add reference to SpectrogramBitmapState
  late SpectrogramBitmapState spectrogramBitmapState;

  // Add reference to RecognitionState (provide externally)
  late RecogniserState
  recognitionState; // replace dynamic with your RecognitionState type if you have it

  StreamSubscription<Uint8List>? _pcmSubscription;

  Isolate? _workerIsolate;
  SendPort? _workerSendPort;
  ReceivePort? _mainReceivePort;

  // Buffer for raw PCM data
  final List<int> _pcmBuffer = [];

  int get _maxFrames => targetFrameWidth;

  MicrophoneState({required this.spectrogramBitmapState, required this.recognitionState});

  Future<void> init() async {
    await _microphoneService.init();
    spectrogramBitmapState.init(bitmapHeight: targetFrameHeight, bitmapWidth: targetFrameWidth * 4);
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
    spectrogramBitmapState.reset();
    _pcmBuffer.clear();

    _mainReceivePort = ReceivePort();
    // Use new worker config and spawn
    final workerConfig = SWConfig(
      _mainReceivePort!.sendPort,
      nFft,
      hopLength,
      targetFrameHeight,
      targetFrameWidth,
    );
    _workerIsolate = await Isolate.spawn(spectrogramWorker, workerConfig);

    _mainReceivePort!.listen((message) {
      if (_workerSendPort == null && message is SendPort) {
        _workerSendPort = message;
      } else if (message is SWSpectrogramFrameMessage) {
        // message.window is List<List<double>> (batch of frames, shape [32,4096])
        // Keep only the last _maxFrames frames in _spectrogram
        for (final frame in message.window) {
          _spectrogram.add(List.from(frame));
          if (_spectrogram.length > _maxFrames) {
            _spectrogram.removeRange(0, _spectrogram.length - _maxFrames);
          }
        }
        // Send batch to bitmap state
        spectrogramBitmapState.addFrames(message.window);

        // Send batch to recognition state if available
        recognitionState?.runInferenceOnFrames(message.window);

        notifyListeners();
      }
    });

    final stream = await _microphoneService.startRecording();
    if (stream != null) {
      _isRecording = true;
      notifyListeners();

      _pcmSubscription = stream.listen((data) {
        _lastVolume = _calculateVolumeDb(data);
        notifyListeners();

        // Add PCM data to buffer (append as bytes)
        _pcmBuffer.addAll(data);

        // Calculate required length for 32 frames
        final int minPcmLen =
            ((targetFrameWidth - 1) * hopLength + nFft) * 2; // *2 for bytes per sample (16bit PCM)
        if (_pcmBuffer.length >= minPcmLen && _workerSendPort != null) {
          // Send only minPcmLen bytes to the worker and remove them from buffer
          final toSend = _pcmBuffer.sublist(0, minPcmLen);
          _workerSendPort?.send(SWPcmDataMessage(toSend));
          _pcmBuffer.removeRange(0, minPcmLen);
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
      _workerSendPort?.send(SWStopMessage());
      _mainReceivePort?.close();
      _workerIsolate?.kill(priority: Isolate.immediate);
      _workerIsolate = null;
      _workerSendPort = null;
      _mainReceivePort = null;
      _pcmBuffer.clear();
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
    dbfs = dbfs.isFinite ? double.parse(dbfs.toStringAsFixed(2)) : -100.0;
    return dbfs;
  }

  List<List<double>> getSpectrogram() => _spectrogram;

  double get getVolume => _lastVolume;
  bool get isRecording => _isRecording;
}
