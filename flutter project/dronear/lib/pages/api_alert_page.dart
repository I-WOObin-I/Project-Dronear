import 'package:flutter/material.dart';
import '../nav/page_nav_info.dart';

class ApiAlertPage extends StatefulWidget implements NavPage {
  @override
  Widget get page => this;
  @override
  String get pageLabel => 'API Alert';
  @override
  IconData get pageIcon => Icons.settings_ethernet;

  const ApiAlertPage({super.key});

  @override
  State<ApiAlertPage> createState() => _ApiAlertPageState();
}

class _ApiAlertPageState extends State<ApiAlertPage> {
  String callType = 'POST';
  final List<String> callTypes = ['GET', 'POST', 'PUT', 'DELETE'];
  String domain = '';
  String key = '';
  String alertPayload = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API for Alerts'),
        backgroundColor: Colors.black87,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'API for Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDropdown<String>(
            label: 'Call type',
            value: callType,
            items: callTypes,
            onChanged: (val) => setState(() => callType = val!),
          ),
          _buildTextInput(
            label: 'Domain',
            value: domain,
            onChanged: (val) => setState(() => domain = val),
          ),
          _buildTextInput(
            label: 'Key',
            value: key,
            onChanged: (val) => setState(() => key = val),
            obscure: true,
          ),
          _buildTextInput(
            label: 'Alert payload',
            value: alertPayload,
            onChanged: (val) => setState(() => alertPayload = val),
            maxLines: 3,
          ),
        ],
      ),
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

  Widget _buildTextInput({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        controller: TextEditingController(text: value)
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: value.length),
          ),
        onChanged: onChanged,
        obscureText: obscure,
        maxLines: maxLines,
      ),
    );
  }
}
