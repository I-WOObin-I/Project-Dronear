import 'package:dronear/state/spectrogram_bitmap_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'state/alerts_state.dart';
import 'state/microphone_state.dart';
import 'state/recogniser_state.dart';
import 'state/spectrogram_bitmap_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final alertsState = AlertsState();
  final spectrogramBitmapState = SpectrogramBitmapState();
  final recogniserState = RecogniserState();
  final microphoneState = MicrophoneState(
    spectrogramBitmapState: spectrogramBitmapState,
    recognitionState: recogniserState,
  );

  await alertsState.init();
  await microphoneState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AlertsState>.value(value: alertsState),
        ChangeNotifierProvider<MicrophoneState>.value(value: microphoneState),
        ChangeNotifierProvider<RecogniserState>.value(value: recogniserState),
        ChangeNotifierProvider<SpectrogramBitmapState>.value(value: spectrogramBitmapState),
      ],
      child: const DroneDetectorApp(),
    ),
  );
}
