import 'package:flutter/material.dart';
import '../../../nav/page_nav_info.dart';
import 'package:provider/provider.dart';
import '../../../state/alerts_state.dart';

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
  DateTime? lastSmsSent;

  @override
  void initState() {
    super.initState();
    final alertsState = context.read<AlertsState>();
    _numberController = TextEditingController(
      text: alertsState.getField(AlertsState.smsAlertNumberKey),
    );
    _textController = TextEditingController(
      text: alertsState.getField(AlertsState.smsAlertContentKey),
    );

    _numberController.addListener(() {
      context.read<AlertsState>().setField(AlertsState.smsAlertNumberKey, _numberController.text);
    });
    _textController.addListener(() {
      context.read<AlertsState>().setField(AlertsState.smsAlertContentKey, _textController.text);
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _testSms() {
    setState(() {
      lastSmsSent = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test SMS sent')));
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = context.watch<AlertsState>();
    final String formattedTime = lastSmsSent?.toLocal().toString() ?? 'Never';

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

            /// Enable SMS Alert switch using alertsState
            SwitchListTile(
              title: const Text('Enable SMS Alert'),
              value: alertsState.getValue(AlertsState.smsAlertEnabledKey),
              onChanged: (val) => alertsState.setValue(AlertsState.smsAlertEnabledKey, val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            /// Include sound file toggle using alertsState
            SwitchListTile(
              title: const Text('Include sound file'),
              value: alertsState.getValue(AlertsState.smsAlertIncludeSoundKey),
              onChanged: (val) => alertsState.setValue(AlertsState.smsAlertIncludeSoundKey, val),
              contentPadding: EdgeInsets.zero,
            ),

            /// Include location toggle using alertsState
            SwitchListTile(
              title: const Text('Include location'),
              value: alertsState.getValue(AlertsState.smsAlertIncludeLocationKey),
              onChanged: (val) => alertsState.setValue(AlertsState.smsAlertIncludeLocationKey, val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Enter the phone number to receive alert SMS. Please include the country code (e.g., +1 for USA, +48 for Poland).',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            const Text('Phone Number', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '+48123456789',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 24),
            const Text('SMS Content', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter message to send in alert SMS...',
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testSms,
              icon: const Icon(Icons.send_to_mobile),
              label: const Text('Test SMS'),
            ),
            Text(
              'Last SMS sent: $formattedTime',
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
