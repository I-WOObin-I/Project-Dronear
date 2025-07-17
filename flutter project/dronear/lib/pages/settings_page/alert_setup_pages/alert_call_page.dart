import 'package:flutter/material.dart';
import '../../../nav/page_nav_info.dart';

class AlertCallPage extends StatefulWidget implements NavPage {
  @override
  Widget get page => this;

  @override
  String get pageLabel => 'Alert Call';

  @override
  IconData get pageIcon => Icons.phone;

  const AlertCallPage({super.key});

  @override
  State<AlertCallPage> createState() => _AlertCallPageState();
}

class _AlertCallPageState extends State<AlertCallPage> {
  final TextEditingController _numberController = TextEditingController();

  bool workInBackground = true;
  bool transmitSound = false;

  DateTime? lastCallTime;

  void _saveSettings() {
    // Stub: here you’d save to persistent storage or state
    final number = _numberController.text;
    debugPrint(
      'Saved: number=$number, background=$workInBackground, sound=$transmitSound',
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  void _testCall() {
    // Stub: this would trigger your call logic
    setState(() {
      lastCallTime = DateTime.now();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Test call initiated')));
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime = 'placeholder for formatted time';

    return Scaffold(
      appBar: AppBar(title: const Text('Alert Call Setup')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Setup Call Alert to receive alerts of drone activity through phone call on a specific number. '
                'Optionally, you can enable sound transmission on call.',
                style: TextStyle(fontSize: 15),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Work in background'),
                value: workInBackground,
                onChanged: (val) => setState(() => workInBackground = val),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Transmit sound'),
                value: transmitSound,
                onChanged: (val) => setState(() => transmitSound = val),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              const Text(
                'Phone Number for Call Alert',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter the phone number to receive alert calls. Please include the country code (e.g., +1 for USA, +48 for Poland).',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                  hintText: '+48123456789',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _testCall,
                    icon: const Icon(Icons.phone_forwarded),
                    label: const Text('Test Call'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Last call made: $formattedTime',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
