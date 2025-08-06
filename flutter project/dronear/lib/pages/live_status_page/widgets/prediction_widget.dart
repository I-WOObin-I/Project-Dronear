import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/recogniser_state.dart';

class PredictionWidget extends StatelessWidget {
  const PredictionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecogniserState>(
      builder: (context, recogniserState, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Display the predicted class name.
              Text(
                recogniserState.predictedClass,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              // Display the confidence percentage.
              Text(
                recogniserState.confidence,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
