import 'package:flutter/material.dart';
import '../../nav/page_nav_info.dart';
import './widgets/status_buttons_widget.dart';
import './widgets/spectrogram_widget.dart';
import './widgets/peers_map_widget.dart';

class LiveStatusPage extends StatelessWidget implements NavPage {
  @override
  Widget get page => this;
  @override
  String get pageLabel => 'Live Status';
  @override
  IconData get pageIcon => Icons.live_tv;

  const LiveStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: const [
            StatusButtonsWidget(
              featureStatus: {
                'CALL': true,
                'SMS': false,
                'MAIL': true,
                'HTTP API': false,
              },
            ),
            SpectrogramWidget(),
            PeersMapWidget(),
          ],
        ),
      ),
    );
  }
}
