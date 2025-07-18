import 'dart:async';
import 'dart:math';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../../services/microphone_service.dart';

class MicrophoneState extends ChangeNotifier {
  final MicrophoneService _microphoneService = MicrophoneService();

  bool _isRecording = false;
  double _lastVolume = -100.0;

  StreamController<Uint8List>? _pcmStreamController;

  Future<void> init() async {
    await _microphoneService.init();
  }

  Future<bool> requestPermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<Stream<Uint8List>?> startRecording() async {
    if (_isRecording) return _pcmStreamController?.stream;

    if (!await requestPermission()) {
      throw Exception('Microphone permission not granted');
    }

    _pcmStreamController = StreamController<Uint8List>();
    final stream = await _microphoneService.startRecording();
    if (stream != null) {
      _isRecording = true;
      notifyListeners();
      stream.listen((data) {
        _lastVolume = _calculateVolume(data);
        notifyListeners();
      });
    }
    return _pcmStreamController?.stream;
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _microphoneService.stopRecording();
      _isRecording = false;
      _lastVolume = -100.0; // Reset volume when stopped
      notifyListeners();
      await _pcmStreamController?.close();
      _pcmStreamController = null;
    }
  }

  double _calculateVolume(Uint8List data) {
    if (data.isEmpty) return -100.0;

    double sum = 0.0;
    final int sampleCount = data.length ~/ 2;

    for (int i = 0; i < data.length - 1; i += 2) {
      int sample = data[i] | (data[i + 1] << 8);
      if (sample >= 0x8000) sample -= 0x10000; // convert to signed 16-bit

      sum += sample * sample;
    }

    double rms = sqrt(sum / sampleCount);
    double db = 20 * log(rms / 32768) / ln10; // dBFS

    return double.parse(db.toStringAsFixed(2)); // Truncate to 2 digits
  }

  double get getVolume => _lastVolume;
  bool get isRecording => _isRecording;
}
