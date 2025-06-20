import 'package:flutter/material.dart';
import '../nav/page_nav_info.dart';

class DetectionPage extends StatelessWidget implements NavPage {
  @override
  Widget get page => this;
  @override
  String get pageLabel => 'Detection';
  @override
  IconData get pageIcon => Icons.sensors;

  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Drone Detection In Progresssss...'));
  }
}
