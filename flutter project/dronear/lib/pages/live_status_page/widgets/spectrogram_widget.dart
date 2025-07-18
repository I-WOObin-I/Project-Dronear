import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../state/microphone_state.dart';

class SpectrogramWidget extends StatelessWidget {
  const SpectrogramWidget({super.key});

  translateVolumeToPercent(double volume) {
    // volume is between -80 and 0 dB, 100% is 0 dB
    if (volume < -80) return 0;
    if (volume > 0) return 100;
    // Normalize to 0-100%
    return ((volume + 80) / 80 * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MicrophoneState>();

    return Consumer<MicrophoneState>(
      builder: (context, micState, child) {
        final barColor = Colors.red;
        return Container(
          padding: AppTheme.cardPadding,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.boxBorderColor),
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Current Volume", style: TextStyle(fontSize: 10)),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: translateVolumeToPercent(micState.getVolume) * 2.0,
                    height: 14,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${micState.getVolume} dB",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
