// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:fl_chart/fl_chart.dart';

// import '../../../state/microphone_state.dart';

// class SpectrogramHistogramWidget extends StatelessWidget {
//   const SpectrogramHistogramWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MicrophoneState>(
//       builder: (context, micState, child) {
//         final List<double> avgDbPerFreq = micState.getFrequencyHistogram();
//         final int nBins = avgDbPerFreq.length;
//         final int sampleRate = micState.sampleRate;
//         final double nyquist = sampleRate / 2;

//         if (avgDbPerFreq.isEmpty) {
//           return Container(
//             height: 160,
//             alignment: Alignment.center,
//             child: const Text("Waiting for audio...", style: TextStyle(color: Colors.grey)),
//           );
//         }

//         // Avoid log(0) by offsetting min freq to 1Hz
//         final double minFreq = 1.0;
//         final double logMin = minFreq.log10();
//         final double logMax = nyquist.log10();

//         // Prepare FlSpots: x = log10-scaled frequency
//         final spots = List<FlSpot>.generate(nBins, (i) {
//           final freq = i * nyquist / nBins;
//           final freqPlot = freq < minFreq ? minFreq : freq;
//           final logFreq = freqPlot.log10();
//           final db = avgDbPerFreq[i].clamp(-140, 0).toDouble();
//           return FlSpot(logFreq, db);
//         });

//         // Define log-frequency ticks at 1, 10, 100, 1k, 10k, Nyquist
//         final List<double> freqTickValues = [1, 10, 100, 1000, 10000, nyquist];
//         final Map<double, String> freqTickLabels = {
//           1.toDouble().log10(): '1 Hz',
//           10.toDouble().log10(): '10 Hz',
//           100.toDouble().log10(): '100 Hz',
//           1000.toDouble().log10(): '1 kHz',
//           10000.toDouble().log10(): '10 kHz',
//           nyquist.toDouble().log10(): '${(nyquist / 1000).toStringAsFixed(0)} kHz',
//         };

//         // Prepare vertical axis labels at -120, -80, -40, 0 dB
//         final List<double> dBLabels = [-120, -80, -40, 0];

//         // Prepare vertical grid ticks for dB
//         final List<double> horizontalGridTicks = dBLabels;
//         // Prepare vertical grid ticks for frequency (on log scale)
//         final List<double> verticalGridTicks = freqTickLabels.keys.toList();

//         return Container(
//           height: 220,
//           margin: const EdgeInsets.all(12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Spectrogram Histogram (Avg dB per Frequency, Log Freq Scale)",
//                 style: TextStyle(fontSize: 13),
//               ),
//               const SizedBox(height: 8),
//               Expanded(
//                 child: LineChart(
//                   LineChartData(
//                     minY: -140,
//                     maxY: 0,
//                     minX: logMin,
//                     maxX: logMax,
//                     titlesData: FlTitlesData(
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 42,
//                           getTitlesWidget: (value, meta) {
//                             if (dBLabels.contains(value)) {
//                               return Text(
//                                 "${value.toInt()} dB",
//                                 style: const TextStyle(color: Colors.black54, fontSize: 10),
//                               );
//                             } else {
//                               return const SizedBox.shrink();
//                             }
//                           },
//                           interval: 40,
//                         ),
//                       ),
//                       rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 42,
//                           getTitlesWidget: (value, meta) {
//                             // Use a small tolerance for floating point comparison
//                             const tol = 0.05;
//                             for (final tick in freqTickLabels.keys) {
//                               if ((value - tick).abs() < tol) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 4),
//                                   child: Text(
//                                     freqTickLabels[tick]!,
//                                     style: const TextStyle(color: Colors.black54, fontSize: 10),
//                                   ),
//                                 );
//                               }
//                             }
//                             return const SizedBox.shrink();
//                           },
//                         ),
//                       ),
//                     ),
//                     borderData: FlBorderData(show: false),
//                     gridData: FlGridData(
//                       show: true,
//                       drawHorizontalLine: true,
//                       horizontalInterval: 40,
//                       getDrawingHorizontalLine: (value) {
//                         if (horizontalGridTicks.contains(value)) {
//                           return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
//                         }
//                         return FlLine(color: Colors.transparent);
//                       },
//                       drawVerticalLine: true,
//                       verticalInterval: null,
//                       checkToShowVerticalLine: (value) {
//                         // Draw grid lines only for major freq ticks
//                         return verticalGridTicks.any((k) => (value - k).abs() < 0.05);
//                       },
//                       getDrawingVerticalLine: (value) {
//                         if (verticalGridTicks.any((k) => (value - k).abs() < 0.05)) {
//                           return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
//                         }
//                         return FlLine(color: Colors.transparent);
//                       },
//                     ),
//                     backgroundColor: Colors.white,
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: spots,
//                         isCurved: false,
//                         color: Colors.deepOrange,
//                         barWidth: 1.5,
//                         dotData: FlDotData(show: false),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     freqTickLabels[freqTickValues.first.log10()] ?? '',
//                     style: const TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                   for (var i = 1; i < freqTickValues.length - 1; i++)
//                     Text(
//                       freqTickLabels[freqTickValues[i].log10()] ?? '',
//                       style: const TextStyle(fontSize: 10, color: Colors.black54),
//                     ),
//                   Text(
//                     freqTickLabels[freqTickValues.last.log10()] ?? '',
//                     style: const TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// // Add this extension to use .log10() on double (for Dart >= 2.15)
// extension _Log10Extension on double {
//   double log10() => (this > 0) ? (math.log(this) / math.ln10) : 0.0;
// }
