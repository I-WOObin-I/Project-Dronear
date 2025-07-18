import 'package:flutter/material.dart';
import '../../../nav/page_nav_info.dart';
import 'package:provider/provider.dart';
import '../../../state/alerts_state.dart';

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

  bool transmitSound = false;
  DateTime? lastCallTime;

  String callAlertNumberKey = 'call_alert_number';
  String callAlertSoundKey = 'call_alert_transmit_sound';

  @override
  void initState() {
    super.initState();

    _numberController.addListener(() {
      context.read<AlertsState>().setField(AlertsState.callAlertNumberKey, _numberController.text);
    });
    _loadSettings();
  }

  void _loadSettings() {
    final alertsState = context.read<AlertsState>();

    final callNumber = alertsState.getField(AlertsState.callAlertNumberKey);
    final transmitSound = alertsState.getValue(AlertsState.callAlertTransmitSoundKey);

    setState(() {
      _numberController.text = callNumber;
      this.transmitSound = transmitSound;
    });
  }

  void _testCall() {
    setState(() {
      lastCallTime = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test call initiated')));
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = context.watch<AlertsState>();

    final String formattedTime = lastCallTime?.toLocal().toString() ?? 'Never';

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

              /// ✅ Toggle call alert on/off
              SwitchListTile(
                title: const Text('Enable Call Alert'),
                value: alertsState.getValue(AlertsState.callAlertEnabledKey),
                onChanged: (val) => alertsState.setValue(AlertsState.callAlertEnabledKey, val),
                contentPadding: EdgeInsets.zero,
              ),

              const Divider(),

              /// ✅ Transmit sound toggle
              SwitchListTile(
                title: const Text('Transmit sound'),
                value: alertsState.getValue(AlertsState.callAlertTransmitSoundKey),
                onChanged: (val) => alertsState.setValue(AlertsState.callAlertTransmitSoundKey, val),
                contentPadding: EdgeInsets.zero,
              ),

              const Divider(),
              const Text('Phone Number for Call Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _testCall,
                icon: const Icon(Icons.phone_forwarded),
                label: const Text('Test Call'),
              ),
              const SizedBox(height: 24),
              Text('Last call made: $formattedTime', style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
