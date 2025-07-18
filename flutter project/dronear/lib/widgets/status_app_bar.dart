import 'package:flutter/material.dart';

enum AlertState { offline, standby, triggered }

class StatusAppBar extends StatelessWidget {
  final bool isOnline;
  final double droneProbability; // value from 0.0 to 1.0
  final AlertState alertState; // 3-state indicator

  const StatusAppBar({
    super.key,
    required this.isOnline,
    required this.droneProbability,
    required this.alertState,
  });

  /// Smoothly interpolate color from green (0) to orange (0.5) to red (1)
  Color interpolateProbabilityColor(double probability) {
    // Clamp probability to [0, 1]
    probability = probability.clamp(0.0, 1.0);

    // Define color stops
    const green = Color(0xFF4CAF50);
    const orange = Color(0xFFFF9800);
    const red = Color(0xFFF44336);

    if (probability < 0.5) {
      // Green to Orange (0.0 -> 0.5)
      double t = probability / 0.5;
      return Color.lerp(green, orange, t)!;
    } else {
      // Orange to Red (0.5 -> 1.0)
      double t = (probability - 0.5) / 0.5;
      return Color.lerp(orange, red, t)!;
    }
  }

  String getProbabilityLabel(double probability) {
    if (probability > 0.7) {
      return 'Likely Drone';
    } else if (probability > 0.3) {
      return 'Possible';
    } else {
      return 'Clear';
    }
  }

  /// Returns icon, color, and label for the alert state
  (IconData, Color, String) getAlertIndicator(AlertState state) {
    switch (state) {
      case AlertState.offline:
        return (Icons.notifications_off, Colors.grey, 'Alert Offline');
      case AlertState.standby:
        return (Icons.notifications, const Color.fromARGB(255, 113, 142, 238), 'Alert Standby');
      case AlertState.triggered:
        return (Icons.crisis_alert, Colors.redAccent, 'Alert Triggered');
    }
  }

  Widget separator() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    height: 24,
    width: 1,
    color: const Color.fromARGB(120, 255, 255, 255),
  );

  @override
  Widget build(BuildContext context) {
    final bool detectionOnline = isOnline;

    final Color probabilityColor = detectionOnline
        ? interpolateProbabilityColor(droneProbability)
        : Colors.grey;

    final String probabilityLabel = detectionOnline
        ? '${(droneProbability * 100).toStringAsFixed(1)}% ${getProbabilityLabel(droneProbability)}'
        : '-';

    final (IconData alarmIcon, Color alarmColor, String alarmLabel) = getAlertIndicator(alertState);

    return AppBar(
      backgroundColor: Colors.black87,
      title: Row(
        children: [
          // Connection Status
          Icon(
            isOnline ? Icons.sensors : Icons.sensors_off,
            color: isOnline ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(color: isOnline ? Colors.green : Colors.red, fontSize: 12),
          ),

          separator(),

          // Drone Probability Indicator
          Icon(Icons.speed, color: probabilityColor, size: 20),
          const SizedBox(width: 6),
          Text(probabilityLabel, style: TextStyle(color: probabilityColor, fontSize: 12)),

          separator(),

          // Alert Indicator
          Icon(alarmIcon, color: alarmColor, size: 20),
          const SizedBox(width: 6),
          Text(alarmLabel, style: TextStyle(color: alarmColor, fontSize: 12)),

          const Spacer(),

          // App title (uncomment if you want)
          // const Text('Drone Detector', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
