import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/tflite_service.dart'; // Assuming your new service is here
import 'microphone_state.dart';

class RecogniserState extends ChangeNotifier {
  final MicrophoneState _microphoneState;
  final TfliteService _tfliteService = TfliteService();

  // The model's expected input dimensions.
  final int _requiredInputHeight = 4096; // Frequency Bins
  final int _requiredInputWidth = 35; // Time Frames

  // Buffer to hold spectrogram frames as they are streamed from the microphone.
  final List<List<double>> _spectrogramBuffer = [];

  Map<String, double>? _predictionResult;
  bool _isRecognising = false;

  RecogniserState(this._microphoneState) {
    _tfliteService.loadModel();
    _microphoneState.addListener(_onMicrophoneStateChanged);
  }

  /// Listens for new audio data and triggers inference when enough data is buffered.
  void _onMicrophoneStateChanged() {
    if (!_microphoneState.isRecording) {
      if (_spectrogramBuffer.isNotEmpty || _predictionResult != null) {
        _spectrogramBuffer.clear();
        _predictionResult = null;
        notifyListeners();
      }
      return;
    }

    // Add newly captured spectrogram frames to our buffer.
    if (_microphoneState.spectrogram.length > _spectrogramBuffer.length) {
      final newFrames = _microphoneState.spectrogram.sublist(_spectrogramBuffer.length);
      _spectrogramBuffer.addAll(newFrames);
    }

    // Once the buffer has enough frames, run the model.
    if (_spectrogramBuffer.length >= _requiredInputWidth) {
      // _runInference();
    }
  }

  /// Prepares the buffered data and passes it to the TFLite service.
  Future<void> _runInference() async {
    if (_isRecognising) return;
    _isRecognising = true;

    // 1. Get the most recent frames required for one inference pass.
    final framesToProcess = _spectrogramBuffer.sublist(
      _spectrogramBuffer.length - _requiredInputWidth,
    );

    // 2. Resize each frame's height to match the model's input dimension.
    // The microphone gives us frames of height (nFft / 2), but the model
    // needs a height of 4096.
    final resizedFrames = framesToProcess.map((frame) {
      return _resizeFrame(frame, _requiredInputHeight);
    }).toList();
    // At this point, `resizedFrames` has a shape of [Width, Height] or [35, 4096].

    // 3. Transpose the data to match the expected [Height, Width] format.
    final inputData = _transpose(resizedFrames);
    // Now, `inputData` has the correct shape of [4096, 35].

    // 4. Run inference using the service.
    _predictionResult = await _tfliteService.runInference(inputData);

    // 5. Implement the "sliding window" by removing the oldest frame.
    // This allows for continuous recognition as new audio comes in.
    _spectrogramBuffer.removeAt(0);

    _isRecognising = false;
    notifyListeners();
  }

  /// Resizes a single audio frame to a target height by padding or truncating.
  List<double> _resizeFrame(List<double> frame, int targetHeight) {
    final currentHeight = frame.length;
    if (currentHeight == targetHeight) {
      return frame;
    }
    if (currentHeight < targetHeight) {
      // Pad with zeros if the frame is too short.
      return frame + List<double>.filled(targetHeight - currentHeight, 0.0);
    }
    // Truncate if the frame is too long.
    return frame.sublist(0, targetHeight);
  }

  /// Transposes a 2D list (swaps rows and columns).
  /// From [width, height] -> [height, width].
  List<List<double>> _transpose(List<List<double>> data) {
    if (data.isEmpty) return [];
    final int width = data.length;
    final int height = data[0].length;

    // Create a new list with the transposed dimensions.
    List<List<double>> transposed = List.generate(height, (_) => List.filled(width, 0.0));

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        transposed[i][j] = data[j][i];
      }
    }
    return transposed;
  }

  // --- Public Accessors for the UI ---

  Map<String, double>? get predictionResult => _predictionResult;

  String get predictedClass {
    if (_predictionResult == null) return "Listening...";
    final classId = _predictionResult!['predictedClass']?.toInt();
    return classId == 0 ? "Class A" : "Class B"; // Map ID to a name
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
