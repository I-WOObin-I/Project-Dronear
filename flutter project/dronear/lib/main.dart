import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/alerts_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final alertsState = AlertsState();
  await alertsState.init(); // Load initial values

  runApp(
    ChangeNotifierProvider<AlertsState>.value(
      value: alertsState,
      child: const DroneDetectorApp(),
    ),
  );
}
