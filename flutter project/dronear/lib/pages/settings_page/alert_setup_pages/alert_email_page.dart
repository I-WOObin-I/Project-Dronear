import 'package:flutter/material.dart';
import '../../../nav/page_nav_info.dart';

// These would come from your persistent storage/provider in a real app.
String savedEmailAddress = 'example@example.com';
String savedSubject = 'Drone Alert ID_DAS_123';
String savedAlertPayload = 'Drone Alert ID_DAS_123';

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

  bool alertEnabled = true;
  bool includeRecording = false;
  bool includeLocation = false;
  String lastEmailSent = 'N/A';

  @override
  void initState() {
    super.initState();

    // Initialize controllers with SAVED values
    _emailController = TextEditingController(text: savedEmailAddress);
    _subjectController = TextEditingController(text: savedSubject);
    _alertPayloadController = TextEditingController(text: savedAlertPayload);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _alertPayloadController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    // Save the current values to your persistent storage or variables
    savedEmailAddress = _emailController.text;
    savedSubject = _subjectController.text;
    savedAlertPayload = _alertPayloadController.text;
    // Optionally show a snackbar or otherwise notify the user
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Alert email settings saved')));
  }

  void _testEmail() {
    // Implement your test email functionality here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test email sent')));
  }

  @override
  Widget build(BuildContext context) {
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
            SwitchListTile(
              title: const Text('Enable Email Alert'),
              value: alertEnabled,
              onChanged: (val) => setState(() => alertEnabled = val),
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
              onChanged: (val) {
                // Optionally update preview or state
                setState(() {});
              },
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
              onChanged: (val) {
                // Optionally update preview or state
                setState(() {});
              },
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
                  onPressed: _testEmail,
                  icon: const Icon(Icons.email),
                  label: const Text('Test Email'),
                ),
              ],
            ),
            Text(
              'Last email sent: $lastEmailSent',
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
