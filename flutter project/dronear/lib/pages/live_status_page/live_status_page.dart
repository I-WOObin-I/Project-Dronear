import 'package:dronear/pages/live_status_page/widgets/prediction_widget.dart';
import 'package:dronear/state/spectrogram_bitmap_state.dart';
import 'package:flutter/material.dart';
import '../../nav/page_nav_info.dart';
import './widgets/status_buttons_widget.dart';
import './widgets/spectrogram_widget.dart';
import './widgets/peers_map_widget.dart';
import './widgets/frequency_widget.dart';
import './widgets/on_off_main_switch_widget.dart';
import './widgets/spectrogram_histogram_widget.dart';
import './widgets/volume_widget.dart';
import '../../config/app_theme.dart';
import '../settings_page/alert_setup_pages/alert_call_page.dart';
import '../settings_page/alert_setup_pages/alert_sms_page.dart';
import '../settings_page/alert_setup_pages/alert_email_page.dart';
import '../settings_page/alert_setup_pages/alert_http_api_page.dart';

class LiveStatusPage extends StatefulWidget implements NavPage {
  const LiveStatusPage({super.key});

  @override
  Widget get page => this;

  @override
  String get pageLabel => 'Live Status';

  @override
  IconData get pageIcon => Icons.live_tv;

  @override
  State<LiveStatusPage> createState() => _LiveStatusPageState();
}

class _LiveStatusPageState extends State<LiveStatusPage> {
  bool detectionEnabled = false;

  final List<Widget> alertPageMap = [
    AlertCallPage(),
    AlertSmsPage(),
    AlertEmailPage(),
    AlertHttpApiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            StatusButtonsWidget(alertPages: alertPageMap),

            Container(
              height: 100,
              margin: EdgeInsets.symmetric(horizontal: AppTheme.cardSideMargin, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: PredictionWidget()),
                  OnOffMainSwitchWidget(),
                ],
              ),
            ),

            // const Expanded(child: PeersMapWidget()),
            // const Expanded(child: FrequencySpectrumWidget()),
            // const Expanded(child: SpectrogramHistogramWidget()),
            const Expanded(child: VolumeWidget()),
            const SizedBox(height: 8),
            const Expanded(child: SpectrogramBitmapWidget()),
          ],
        ),
      ),
    );
  }
}
