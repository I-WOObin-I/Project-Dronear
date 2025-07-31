import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../state/microphone_state.dart';

class FrequencySpectrumWidget extends StatelessWidget {
  const FrequencySpectrumWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MicrophoneState>(
      builder: (context, micState, child) {
        // Use the new method to get the current spectrum!
        final List<double> spectrum = micState.getCurrentFrequencySpectrum();
        final int nBins = spectrum.length;
        final int sampleRate = micState.sampleRate;
        final double nyquist = sampleRate / 2;

        if (spectrum.isEmpty) {
          return Container(
            height: 160,
            alignment: Alignment.center,
            child: const Text("Waiting for audio...", style: TextStyle(color: Colors.grey)),
          );
        }

        // Prepare one FlSpot per FFT bin (X: frequency, Y: dB normalized)
        final spots = List<FlSpot>.generate(nBins, (i) {
          final freq = i * nyquist / nBins;
          final db = spectrum[i].clamp(-140, 0); // clamp to visible dB range
          final y = (db + 140) / 140 * 100; // normalize for chart
          return FlSpot(freq, y);
        });

        return Container(
          height: 160,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Frequency Spectrum", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 100,
                    minX: 0,
                    maxX: nyquist,
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    backgroundColor: Colors.white,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 1.5,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "0 Hz        ~${(nyquist ~/ 1000).toStringAsFixed(1)} kHz",
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }
}
