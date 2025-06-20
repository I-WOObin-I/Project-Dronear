import 'package:flutter/material.dart';
import '../nav/page_nav_info.dart';

class HomePage extends StatelessWidget implements NavPage {
  @override
  Widget get page => this;
  @override
  String get pageLabel => 'Home';
  @override
  IconData get pageIcon => Icons.home;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Welcome to Drone Detector'));
  }
}
