import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/logger.dart';

class TfliteService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      // Create an interpreter from the asset
      // _interpreter = await Interpreter.fromAsset('assets/model_v7.tflite');
      print('TFLite model loaded successfully.');
    } catch (e) {
      print('Error loading TFLite model: $e');
    }
  }

  Future<Map<String, double>?> runInference(List<List<double>> inputData) async {
    // change [H, W] to [1, 1, H, W] which stands for: batch size, channels, height, width and N and C are 1
    var reshapedInput = inputData.reshape([1, 1, inputData.length, inputData[0].length]);
    logger.i('Reshaped input shape: ${reshapedInput.shape}');
    logger.i('Input data: $reshapedInput');

    if (!kIsWeb && _interpreter.isAllocated == false) {
      logger.e('Interpreter not allocated.');
      return null;
    }

    // The output will have shape [1, 2] for your binary classification.
    var output = List.filled(1 * 2, 0.0).reshape([1, 2]);

    // Run inference
    _interpreter.run(reshapedInput, output);

    // Process the output
    var outputList = output[0] as List<double>;

    // Apply softmax to get probabilities
    final probabilities = _softmax(outputList);

    // Find the predicted class and its confidence
    int predictedClass = 0;
    double confidence = 0.0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > confidence) {
        confidence = probabilities[i];
        predictedClass = i;
      }
    }

    return {
      'predictedClass': predictedClass.toDouble(),
      'confidence': confidence * 100.0, // Return as a percentage
    };
  }

  // Simple softmax implementation - NOW CORRECT
  List<double> _softmax(List<double> input) {
    final exps = input.map((e) => exp(e)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  void dispose() {
    _interpreter.close();
  }
}
