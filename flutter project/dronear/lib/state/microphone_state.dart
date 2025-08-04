import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/microphone_service.dart';
import '../utils/logger.dart';
import '../utils/spectrogram_worker.dart';
import 'spectrogram_bitmap_state.dart'; // <-- Import your bitmap state here

class MicrophoneState extends ChangeNotifier {
  final MicrophoneService _microphoneService = MicrophoneService();

  bool _isRecording = false;
  double _lastVolume = -100.0;

  // Config
  final int sampleRate = 48000;
  final int nFft = 1024;
  final int hopLength = 512;
  final int spectrogramDurationSec = 5;
  final int targetFrameHeight = 1024 ~/ 2;
  late final int targetFrameWidth = ((sampleRate * spectrogramDurationSec - nFft) ~/ hopLength) + 1;

  final List<List<double>> _spectrogram = [];

  // Add reference to SpectrogramBitmapState
  late SpectrogramBitmapState spectrogramBitmapState;

  StreamSubscription<Uint8List>? _pcmSubscription;

  Isolate? _workerIsolate;
  SendPort? _workerSendPort;
  ReceivePort? _mainReceivePort;

  int get _maxFrames => targetFrameWidth;

  MicrophoneState({required this.spectrogramBitmapState});

  Future<void> init() async {
    await _microphoneService.init();
    spectrogramBitmapState.init(bitmapHeight: targetFrameHeight, bitmapWidth: targetFrameWidth);
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
        // message.frame is List<List<double>> (batch of frames)
        for (final frame in message.frame) {
          _spectrogram.add(List.from(frame));
          if (_spectrogram.length > _maxFrames) {
            _spectrogram.removeRange(0, _spectrogram.length - _maxFrames);
          }
        }
        // Send batch to bitmap state
        spectrogramBitmapState.addFrames(message.frame);
        notifyListeners();
      }
    });

    final stream = await _microphoneService.startRecording();
    if (stream != null) {
      _isRecording = true;
      notifyListeners();

      _pcmSubscription = stream.listen((data) {
        _lastVolume = _calculateVolumeDb(data);

        if (_workerSendPort != null) {
          _workerSendPort?.send(SWPcmDataMessage(data));
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
