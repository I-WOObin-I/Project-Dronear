import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../nav/page_nav_info.dart';
import '../../../config/app_theme.dart';

String savedHttpUrl = 'https://example.com/alert';
String savedHttpMethod = 'POST';
String savedHttpHeaders = '{"Content-Type": "application/json"}';
String savedMessageContent = 'Drone Alert ID_DAS_123';
bool savedIncludeRecording = false;
bool savedIncludeLocation = false;

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

  bool alertEnabled = true;
  bool includeRecording = savedIncludeRecording;
  bool includeLocation = savedIncludeLocation;

  String lastSentTime = 'N/A';

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: savedHttpUrl);
    _headersController = TextEditingController(text: savedHttpHeaders);
    _messageController = TextEditingController(text: savedMessageContent);
    _selectedMethod = savedHttpMethod;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _headersController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _generatedPayload => {
    "message": _messageController.text,
    "location": includeLocation ? "LAT: 00.0000, LNG: 00.0000" : "N/A",
    "recordingAttached": includeRecording,
  };

  void _saveSettings() {
    savedHttpUrl = _urlController.text;
    savedHttpMethod = _selectedMethod;
    savedHttpHeaders = _headersController.text;
    savedMessageContent = _messageController.text;
    savedIncludeRecording = includeRecording;
    savedIncludeLocation = includeLocation;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('HTTP API alert settings saved')),
    );
  }

  void _testHttpAlert() {
    setState(() {
      lastSentTime = DateTime.now().toIso8601String();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test HTTP alert sent'),
        duration: AppTheme.testAlertDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generatedPayloadJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(_generatedPayload);

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
            const SizedBox(height: 16),
            const Text(
              'API Endpoint URL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'https://example.com/api/alert',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'HTTP Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: _httpMethods
                  .map(
                    (method) =>
                        DropdownMenuItem(value: method, child: Text(method)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedMethod = value);
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text(
              'HTTP Headers (JSON)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _headersController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '{"Content-Type": "application/json"}',
              ),
            ),
            const Text(
              'Message Content',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter alert message...',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const Text(
              'Generated Payload',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                generatedPayloadJson,
                style: const TextStyle(fontFamily: 'monospace'),
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
                  onPressed: _testHttpAlert,
                  icon: const Icon(Icons.send),
                  label: const Text('Test HTTP Alert'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Last alert sent: $lastSentTime',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
