import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/alerts_state.dart';
import 'state/microphone_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final alertsState = AlertsState();
  final microphoneState = MicrophoneState();
  await alertsState.init();
  await microphoneState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AlertsState>.value(value: alertsState),
        ChangeNotifierProvider<MicrophoneState>.value(value: microphoneState),
      ],
      child: const DroneDetectorApp(),
    ),
  );
}
