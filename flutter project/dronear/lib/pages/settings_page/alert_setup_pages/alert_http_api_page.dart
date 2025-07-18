import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../nav/page_nav_info.dart';
import '../../../config/app_theme.dart';
import '../../../state/alerts_state.dart';
import 'package:provider/provider.dart';

class AlertHttpApiPage extends StatefulWidget implements NavPage {
  const AlertHttpApiPage({super.key});

  @override
  Widget get page => this;

  @override
  String get pageLabel => 'HTTP API Alert';

  @override
  IconData get pageIcon => Icons.settings_ethernet;

  @override
  State<AlertHttpApiPage> createState() => _AlertHttpApiPageState();
}

class _AlertHttpApiPageState extends State<AlertHttpApiPage> {
  late TextEditingController _urlController;
  late TextEditingController _headersController;
  late TextEditingController _messageController;

  final List<String> _httpMethods = ['POST', 'GET', 'PUT', 'DELETE', 'PATCH'];
  late String _selectedMethod;
  String? lastSentTime;

  @override
  void initState() {
    super.initState();
    final alertsState = context.read<AlertsState>();

    _urlController = TextEditingController(
      text: alertsState.getField(AlertsState.httpApiAlertUrlKey),
    );
    _headersController = TextEditingController(
      text: alertsState.getField(AlertsState.httpApiAlertHeadersKey),
    );
    _messageController = TextEditingController(
      text: alertsState.getField(AlertsState.httpApiAlertMessageKey),
    );

    _selectedMethod = alertsState.getField(AlertsState.httpApiAlertMethodKey);

    _urlController.addListener(() {
      context.read<AlertsState>().setField(AlertsState.httpApiAlertUrlKey, _urlController.text);
    });
    _headersController.addListener(() {
      context.read<AlertsState>().setField(
        AlertsState.httpApiAlertHeadersKey,
        _headersController.text,
      );
    });
    _messageController.addListener(() {
      context.read<AlertsState>().setField(
        AlertsState.httpApiAlertMessageKey,
        _messageController.text,
      );
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _headersController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _generatedPayload {
    final alertsState = context.read<AlertsState>();
    return {
      "message": _messageController.text,
      "location": alertsState.getValue(AlertsState.httpApiAlertIncludeLocationKey)
          ? "LAT: 00.0000, LNG: 00.0000"
          : "N/A",
      "recordingAttached": alertsState.getValue(AlertsState.httpApiAlertIncludeSoundKey),
    };
  }

  void _testHttpAlert() {
    setState(() {
      lastSentTime = DateTime.now().toLocal().toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test HTTP alert sent'), duration: AppTheme.testAlertDuration),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = context.watch<AlertsState>();
    final generatedPayloadJson = const JsonEncoder.withIndent('  ').convert(_generatedPayload);
    final String formattedTime = lastSentTime ?? 'N/A';

    return Scaffold(
      appBar: AppBar(title: const Text('HTTP API Alert Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure alert notifications through HTTP API. '
              'Specify endpoint, HTTP method, headers, and alert body. '
              'Payload is generated automatically.',
              style: TextStyle(fontSize: 15),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Enable HTTP API Alert'),
              value: alertsState.getValue(AlertsState.httpApiAlertEnabledKey),
              onChanged: (val) => alertsState.setValue(AlertsState.httpApiAlertEnabledKey, val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Include sound recording file'),
              value: alertsState.getValue(AlertsState.httpApiAlertIncludeSoundKey),
              onChanged: (val) =>
                  alertsState.setValue(AlertsState.httpApiAlertIncludeSoundKey, val),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Include location'),
              value: alertsState.getValue(AlertsState.httpApiAlertIncludeLocationKey),
              onChanged: (val) =>
                  alertsState.setValue(AlertsState.httpApiAlertIncludeLocationKey, val),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const SizedBox(height: 16),
            const Text('API Endpoint URL', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://example.com/api/alert',
              ),
            ),
            const SizedBox(height: 16),
            const Text('HTTP Method', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: _httpMethods
                  .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                  context.read<AlertsState>().setField(AlertsState.httpApiAlertMethodKey, value);
                }
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('HTTP Headers (JSON)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _headersController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '{"Content-Type": "application/json"}',
              ),
            ),
            const Text('Message Content', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter alert message...',
              ),
            ),
            const SizedBox(height: 24),
            const Text('Generated Payload', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(generatedPayloadJson, style: const TextStyle(fontFamily: 'monospace')),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _testHttpAlert,
              icon: const Icon(Icons.send),
              label: const Text('Test HTTP Alert'),
            ),
            const SizedBox(height: 16),
            Text(
              'Last alert sent: $formattedTime',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
