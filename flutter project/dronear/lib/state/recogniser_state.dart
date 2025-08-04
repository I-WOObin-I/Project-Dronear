import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/tflite_service.dart';
import 'microphone_state.dart';
import '../utils/logger.dart';

class RecogniserState extends ChangeNotifier {
  final MicrophoneState _microphoneState;
  final TfliteService _tfliteService = TfliteService();

  // The model's expected input dimensions.
  final int _requiredInputHeight = 4096; // Frequency Bins
  final int _requiredInputWidth = 35; // Time Frames

  Stopwatch _inferenceStopwatch = Stopwatch();

  final List<List<double>> _spectrogramBuffer = [];
  Map<String, double>? _predictionResult;
  bool _isRecognising = false;
  bool _recognitionEnabled = false;

  RecogniserState(this._microphoneState) {
    _tfliteService.loadModel();
    _microphoneState.addListener(_onMicrophoneStateChanged);
  }

  void _onMicrophoneStateChanged() {
    if (!_recognitionEnabled) return;
    if (!_microphoneState.isRecording) {
      if (_spectrogramBuffer.isNotEmpty || _predictionResult != null) {
        _spectrogramBuffer.clear();
        _predictionResult = null;
        notifyListeners();
      }
      return;
    }

    // Use the accessor to get the latest frames from MicrophoneState
    final micSpectrogram = _microphoneState.getSpectrogram();
    if (micSpectrogram.length > _spectrogramBuffer.length) {
      final newFrames = micSpectrogram.sublist(_spectrogramBuffer.length);
      _spectrogramBuffer.addAll(newFrames);
    }

    // Trigger recognition when enough frames are available
    if (_spectrogramBuffer.length >= _requiredInputWidth) {
      _runInference();
    }
  }

  Future<void> _runInference() async {
    if (_isRecognising) return;
    _isRecognising = true;

    final framesToProcess = _spectrogramBuffer.sublist(
      _spectrogramBuffer.length - _requiredInputWidth,
    );

    final resizedFrames = framesToProcess.map((frame) {
      return _resizeFrame(frame, _requiredInputHeight);
    }).toList();

    final inputData = _transpose(resizedFrames);

    _inferenceStopwatch.start();
    _predictionResult = await _tfliteService.runInference(inputData);
    _inferenceStopwatch.stop();

    logger.i("[PERF] Inference time: ${_inferenceStopwatch.elapsedMilliseconds}ms");

    _inferenceStopwatch.reset();

    // Sliding window: remove oldest frame
    _spectrogramBuffer.removeAt(0);

    _isRecognising = false;
    notifyListeners();
  }

  List<double> _resizeFrame(List<double> frame, int targetHeight) {
    final currentHeight = frame.length;
    if (currentHeight == targetHeight) {
      return frame;
    }
    if (currentHeight < targetHeight) {
      return frame + List<double>.filled(targetHeight - currentHeight, 0.0);
    }
    return frame.sublist(0, targetHeight);
  }

  List<List<double>> _transpose(List<List<double>> data) {
    if (data.isEmpty) return [];
    final int width = data.length;
    final int height = data[0].length;
    List<List<double>> transposed = List.generate(height, (_) => List.filled(width, 0.0));
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        transposed[i][j] = data[j][i];
      }
    }
    return transposed;
  }

  Map<String, double>? get predictionResult => _predictionResult;

  String get predictedClass {
    if (_predictionResult == null) return "Listening...";
    final classId = _predictionResult!['predictedClass']?.toInt();
    return classId == 0 ? "No Drone" : "Drone Detected";
  }

  String get confidence {
    if (_predictionResult == null) return "";
    return "${_predictionResult!['confidence']?.toStringAsFixed(1)}%";
  }

  @override
  void dispose() {
    _microphoneState.removeListener(_onMicrophoneStateChanged);
    super.dispose();
  }
}
