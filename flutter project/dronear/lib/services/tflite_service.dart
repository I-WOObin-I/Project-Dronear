import 'dart:math';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';

class TfliteService {
  Interpreter? _interpreter;
  Uint8List? _modelBytes;

  /// Load the model into memory and create the interpreter in the main isolate.
  Future<void> loadModel() async {
    try {
      logger.i('Loading TFLite model from assets...');
      _modelBytes = (await rootBundle.load('assets/model_v7_set3.tflite')).buffer.asUint8List();
      logger.i('TFLite model loaded from assets.');
      _interpreter = Interpreter.fromBuffer(_modelBytes!);
      logger.i('TFLite model loaded successfully.');
    } catch (e) {
      logger.e('Error loading TFLite model: $e');
    }
  }

  /// Run inference in a background isolate using Isolate API (not compute).
  Future<Map<String, double>?> runInference(List<List<double>> inputData) async {
    if (_modelBytes == null) {
      logger.e('Model not loaded.');
      return {'predictedClass': -1, 'confidence': -1.0};
    }

    // Set up isolate communication
    final responsePort = ReceivePort();
    await Isolate.spawn<_IsolateArgs>(
      _inferenceIsolateEntry,
      _IsolateArgs(inputData: inputData, modelBytes: _modelBytes!, sendPort: responsePort.sendPort),
    );

    // Wait for response from the isolate
    return await responsePort.first as Map<String, double>?;
  }

  /// The entry point for the spawned isolate.
  static void _inferenceIsolateEntry(_IsolateArgs args) async {
    final result = await _runInferenceWorker(args.inputData, args.modelBytes);
    args.sendPort.send(result);
  }

  /// Actual inference logic, used in isolate.
  static Future<Map<String, double>?> _runInferenceWorker(
    List<List<double>> inputData,
    Uint8List modelBytes,
  ) async {
    final interpreter = Interpreter.fromBuffer(modelBytes);

    // Reshape [H, W] -> [1, 1, H, W]
    var reshapedInput = _reshapeInput(inputData);
    var output = List.filled(1 * 2, 0.0).reshape([1, 2]);
    interpreter.run(reshapedInput, output);

    var outputList = output[0];
    final probabilities = _softmax(outputList);

    int predictedClass = 0;
    double confidence = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > confidence) {
        confidence = probabilities[i];
        predictedClass = i;
      }
    }

    interpreter.close();
    logger.i(
      'Inference completed: predictedClass=$predictedClass, confidence=$confidence, \t logits=$outputList',
    );

    return {'predictedClass': predictedClass.toDouble(), 'confidence': confidence * 100.0};
  }

  /// Utility to reshape input for TFLite model: [H, W] -> [1, 1, H, W]
  static List<List<List<double>>> _reshapeInput(List<List<double>> input) {
    return [input];
  }

  /// Softmax implementation for output probabilities
  static List<double> _softmax(List<double> input) {
    final exps = input.map((e) => exp(e)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  void dispose() {
    _interpreter?.close();
  }
}

/// Helper class for passing multiple arguments to the isolate
class _IsolateArgs {
  final List<List<double>> inputData;
  final Uint8List modelBytes;
  final SendPort sendPort;

  _IsolateArgs({required this.inputData, required this.modelBytes, required this.sendPort});
}

// Extension for reshaping output buffer
extension ReshapeList2D on List<double> {
  List<List<double>> reshape(List<int> shape) {
    final rows = shape[0];
    final cols = shape[1];
    List<List<double>> result = List.generate(rows, (_) => List.filled(cols, 0.0));
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        result[r][c] = this[r * cols + c];
      }
    }
    return result;
  }
}
