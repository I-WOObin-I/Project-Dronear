import 'package:flutter/material.dart';
import '../../../nav/page_nav_info.dart';
import 'package:provider/provider.dart';
import '../../../state/alerts_state.dart';

class AlertEmailPage extends StatefulWidget implements NavPage {
  @override
  Widget get page => this;
  @override
  String get pageLabel => 'Alert Email';
  @override
  IconData get pageIcon => Icons.email;

  const AlertEmailPage({super.key});

  @override
  State<AlertEmailPage> createState() => _AlertEmailPageState();
}

class _AlertEmailPageState extends State<AlertEmailPage> {
  late TextEditingController _emailController;
  late TextEditingController _subjectController;
  late TextEditingController _alertPayloadController;
  DateTime? lastEmailSent;

  @override
  void initState() {
    super.initState();
    final alertsState = context.read<AlertsState>();
    _emailController = TextEditingController(
      text: alertsState.getField(AlertsState.emailAlertAddressKey),
    );
    _subjectController = TextEditingController(
      text: alertsState.getField(AlertsState.emailAlertSubjectKey),
    );
    _alertPayloadController = TextEditingController(
      text: alertsState.getField(AlertsState.emailAlertPayloadKey),
    );

    _emailController.addListener(() {
      context.read<AlertsState>().setField(AlertsState.emailAlertAddressKey, _emailController.text);
    });
    _subjectController.addListener(() {
      context.read<AlertsState>().setField(
        AlertsState.emailAlertSubjectKey,
        _subjectController.text,
      );
    });
    // The payload is read-only, set by the app logic elsewhere
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _alertPayloadController.dispose();
    super.dispose();
  }

  void _testEmail() {
    setState(() {
      lastEmailSent = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test email sent')));
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = context.watch<AlertsState>();
    final String formattedTime = lastEmailSent?.toLocal().toString() ?? 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('Alert Email Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup Email Alert to receive alerts of drone activity through email. '
              'Optionally, you can include sound recording of recognized drone and location information. '
              'Recording will be sent as an attachment. Location will be included in the email body at the end.',
              style: TextStyle(fontSize: 15),
            ),
            const Divider(),

            /// Enable Email Alert switch using alertsState
            SwitchListTile(
              title: const Text('Enable Email Alert'),
              value: alertsState.getValue(AlertsState.emailAlertEnabledKey),
              onChanged: (val) => alertsState.setValue(AlertsState.emailAlertEnabledKey, val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            /// Include sound file toggle using alertsState
            SwitchListTile(
              title: const Text('Include sound file'),
              value: alertsState.getValue(AlertsState.emailAlertIncludeSoundKey),
              onChanged: (val) => alertsState.setValue(AlertsState.emailAlertIncludeSoundKey, val),
              contentPadding: EdgeInsets.zero,
            ),

            /// Include location toggle using alertsState
            SwitchListTile(
              title: const Text('Include location'),
              value: alertsState.getValue(AlertsState.emailAlertIncludeLocationKey),
              onChanged: (val) =>
                  alertsState.setValue(AlertsState.emailAlertIncludeLocationKey, val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const Text(
              'Enter the email address and subject to receive alert emails.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'user@example.com',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email Subject',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _subjectController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter email subject...',
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testEmail,
              icon: const Icon(Icons.email),
              label: const Text('Test Email'),
            ),
            Text(
              'Last email sent: $formattedTime',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Email Payload Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _alertPayloadController,
              maxLines: 3,
              readOnly: true,
              enabled: false,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
