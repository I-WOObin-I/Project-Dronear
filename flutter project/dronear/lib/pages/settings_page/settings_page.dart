import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../nav/page_nav_info.dart';
// Import your alert setup pages
import './alert_setup_pages/alert_call_page.dart';
import './alert_setup_pages/alert_sms_page.dart';
import './alert_setup_pages/alert_email_page.dart';
import './alert_setup_pages/alert_http_api_page.dart';

class SettingsPage extends StatefulWidget implements NavPage {
  @override
  Widget get page => this;
  @override
  String get pageLabel => 'Settings';
  @override
  IconData get pageIcon => Icons.settings;

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Calibration settings
  double droneConfidenceThreshold = 0.7;
  double noDroneConfidenceThreshold = 0.2;
  double alertThreshold = 0.8;
  double recognitionFrequency = 10.0; // times per second, default 10
  String recognitionModel = 'Model A';
  final List<String> recognitionModels = ['Model A', 'Model B', 'Model C'];

  // Text controllers for numeric input fields
  late TextEditingController droneConfidenceController;
  late TextEditingController noDroneConfidenceController;
  late TextEditingController alertThresholdController;
  late TextEditingController recognitionFrequencyController;

  // App settings
  bool workInBackground = true;

  // Alert setup pages
  final List<NavPage> alertPages = [
    AlertCallPage(),
    AlertSmsPage(),
    AlertEmailPage(),
    AlertHttpApiPage(),
  ];

  @override
  void initState() {
    super.initState();
    droneConfidenceController = TextEditingController(
      text: droneConfidenceThreshold.toStringAsFixed(2),
    );
    noDroneConfidenceController = TextEditingController(
      text: noDroneConfidenceThreshold.toStringAsFixed(2),
    );
    alertThresholdController = TextEditingController(
      text: alertThreshold.toStringAsFixed(2),
    );
    recognitionFrequencyController = TextEditingController(
      text: recognitionFrequency.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    droneConfidenceController.dispose();
    noDroneConfidenceController.dispose();
    alertThresholdController.dispose();
    recognitionFrequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Settings Section Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Work in background'),
                  value: workInBackground,
                  onChanged: (val) => setState(() => workInBackground = val),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 16),

          // Alerts Section Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alerts Setup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Column(
                  children: alertPages.map((page) {
                    return _buildAlertSetupButton(
                      context,
                      icon: page.pageIcon,
                      label: page.pageLabel,
                      page: page.page,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSetupButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      },
      shape: const Border(
        bottom: BorderSide(color: Color(0xFFE0E0E0)), // subtle divider
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _buildSliderWithInput({
    required String label,
    required double value,
    required double min,
    required double max,
    required TextEditingController controller,
    required ValueChanged<double> onChanged,
    required ValueChanged<String> onInputChanged,
    int decimals = 2,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: ((max - min) * (decimals == 1 ? 10 : 100)).round(),
                label: value.toStringAsFixed(decimals),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                onChanged: onInputChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (e) => DropdownMenuItem<T>(
                      value: e,
                      child: Text(e.toString()),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
