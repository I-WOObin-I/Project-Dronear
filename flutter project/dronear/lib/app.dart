import 'package:dronear/nav/page_nav_info.dart';
import 'package:dronear/pages/api_alert_page.dart';
import 'package:dronear/pages/calibration_page.dart';
import 'package:flutter/material.dart';
import 'pages/detection_page.dart';
import 'pages/settings_page.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/status_app_bar.dart';

class DroneDetectorApp extends StatefulWidget {
  const DroneDetectorApp({super.key});

  @override
  State<DroneDetectorApp> createState() => _DroneDetectorAppState();
}

class _DroneDetectorAppState extends State<DroneDetectorApp> {
  int _currentIndex = 0;

  final _pages = [
    DetectionPage(),
    CalibrationPage(),
    ApiAlertPage(),
    SettingsPage(),
  ];

  // final List<NavPage> _pages = [
  //   DetectionPage(),
  //   CalibrationPage(),
  //   ApiAlertPage(),
  //   SettingsPage(),
  // ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Detector',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Column(
          children: [
            const StatusAppBar(
              isOnline: true,
              droneProbability: 0.36,
              alertState: AlertState.standby,
            ),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          pages: _pages.map((page) => page as NavPage).toList(),
        ),
      ),
    );
  }
}
