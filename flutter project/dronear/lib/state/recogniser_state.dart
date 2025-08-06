import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/tflite_service.dart';
import 'microphone_state.dart';
import '../utils/logger.dart';

class RecogniserState extends ChangeNotifier {
  final TfliteService _tfliteService = TfliteService();

  // The model's expected input dimensions.
  final int _requiredInputHeight = 4096; // Frequency Bins
  final int _requiredInputWidth = 32; // Time Frames

  Stopwatch _inferenceStopwatch = Stopwatch();

  Map<String, double>? _predictionResult;
  bool _isRecognising = false;
  bool _recognitionEnabled = true;

  RecogniserState() {
    _tfliteService.loadModel();
    // No longer listening to mic state changes for auto-inference
  }

  /// Call this method to manually run inference on the given frames
  /// [frames] should be a List<List<double>> of shape [timeFrames, freqBins], e.g. [32, 4096]
  Future<void> runInferenceOnFrames(List<List<double>> frames) async {
    if (!_recognitionEnabled) return;
    if (_isRecognising) return;
    if (frames.length < _requiredInputWidth) return;
    _isRecognising = true;

    // Take the last _requiredInputWidth frames
    final framesToProcess = frames.sublist(frames.length - _requiredInputWidth);

    // Ensure each frame is resized to required height
    final resizedFrames = framesToProcess.map((frame) {
      return _resizeFrame(frame, _requiredInputHeight);
    }).toList();

    // Model expects [freqBins, timeFrames]
    final inputData = _transpose(resizedFrames);

    _inferenceStopwatch.start();
    _predictionResult = await _tfliteService.runInference(inputData);
    _inferenceStopwatch.stop();

    logger.i("[PERF] Inference time: ${_inferenceStopwatch.elapsedMilliseconds}ms");

    _inferenceStopwatch.reset();

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
    super.dispose();
  }
}
