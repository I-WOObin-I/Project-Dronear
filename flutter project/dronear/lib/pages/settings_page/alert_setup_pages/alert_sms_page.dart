import 'package:flutter/material.dart';
import '../../../nav/page_nav_info.dart';
import 'package:provider/provider.dart';
import '../../../state/alerts_state.dart';

// Example of variables that could be loaded/saved from persistent storage.
String savedPhoneNumber = '+48123456789';
String savedSmsContent = 'Drone alert detected!';
bool savedAlertEnabled = true;
bool savedIncludeRecording = false;
bool savedIncludeLocation = false;

class AlertSmsPage extends StatefulWidget implements NavPage {
  @override
  Widget get page => this;
  @override
  String get pageLabel => 'Alert SMS';
  @override
  IconData get pageIcon => Icons.sms;

  const AlertSmsPage({super.key});

  @override
  State<AlertSmsPage> createState() => _AlertSmsPageState();
}

class _AlertSmsPageState extends State<AlertSmsPage> {
  late TextEditingController _numberController;
  late TextEditingController _textController;

  bool alertEnabled = true;
  bool includeRecording = false;
  bool includeLocation = false;
  String lastSmsSent = 'Never';

  @override
  void initState() {
    super.initState();
    // Initialize controllers and switches from saved variables
    _numberController = TextEditingController(text: savedPhoneNumber);
    _textController = TextEditingController(text: savedSmsContent);
    alertEnabled = savedAlertEnabled;
    includeRecording = savedIncludeRecording;
    includeLocation = savedIncludeLocation;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // Save the current values to your persistent storage or variables
    savedPhoneNumber = _numberController.text;
    savedSmsContent = _textController.text;
    savedAlertEnabled = alertEnabled;
    savedIncludeRecording = includeRecording;
    savedIncludeLocation = includeLocation;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Alert SMS settings saved')));
  }

  void _testSms() {
    // Implement your test SMS functionality here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test SMS sent')));
    lastSmsSent = DateTime.now().toIso8601String(); // Update last sent time
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = context.watch<AlertsState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alert SMS Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup SMS Alert to receive alerts of drone activity through SMS message. '
              'Optionally, you can include sound recording of recognized drone and location information. '
              'These will be sent as separate messages with SMS content.',
              style: TextStyle(fontSize: 15),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Enable SMS Alert'),
              value: alertsState.isSmsEnabled,
              onChanged: (val) => alertsState.toggleSms(val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Include sound recording file'),
              value: includeRecording,
              onChanged: (val) => setState(() => includeRecording = val),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Include location'),
              value: includeLocation,
              onChanged: (val) => setState(() => includeLocation = val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Enter the phone number to receive alert SMS. Please include the country code (e.g., +1 for USA, +48 for Poland).',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            const Text(
              'Phone Number',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '+48123456789',
                prefixIcon: Icon(Icons.phone),
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const Text(
              'SMS Content',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter message to send in alert SMS...',
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _testSms,
                  icon: const Icon(Icons.send_to_mobile),
                  label: const Text('Test SMS'),
                ),
              ],
            ),
            Text(
              'Last SMS sent: $lastSmsSent',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
