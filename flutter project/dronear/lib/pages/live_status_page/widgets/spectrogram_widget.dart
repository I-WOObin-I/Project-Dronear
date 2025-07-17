import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';

class SpectrogramWidget extends StatelessWidget {
  const SpectrogramWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.cardPadding,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.boxBorderColor),
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
      ),
      child: const Center(
        child: Text(
          "Live spectrogram visualisation",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
