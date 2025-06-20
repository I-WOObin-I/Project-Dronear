import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../nav/page_nav_info.dart';

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

  // API for Alerts settings
  String callType = 'POST';
  final List<String> callTypes = ['GET', 'POST', 'PUT', 'DELETE'];
  String domain = '';
  String key = '';
  String alertPayload = '';

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
      // appBar: AppBar(
      //   title: const Text('Settings'),
      //   backgroundColor: Colors.black87,
      // ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Calibration Section
          const Text(
            'Calibration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSliderWithInput(
            label: 'Drone confidence threshold',
            value: droneConfidenceThreshold,
            min: 0.0,
            max: 1.0,
            controller: droneConfidenceController,
            decimals: 2,
            onChanged: (val) {
              setState(() {
                droneConfidenceThreshold = val;
                droneConfidenceController.text = val.toStringAsFixed(2);
              });
            },
            onInputChanged: (val) {
              final parsed = double.tryParse(val);
              if (parsed != null && parsed >= 0.0 && parsed <= 1.0) {
                setState(() {
                  droneConfidenceThreshold = parsed;
                });
              }
            },
          ),
          _buildSliderWithInput(
            label: 'No drone confidence threshold',
            value: noDroneConfidenceThreshold,
            min: 0.0,
            max: 1.0,
            controller: noDroneConfidenceController,
            decimals: 2,
            onChanged: (val) {
              setState(() {
                noDroneConfidenceThreshold = val;
                noDroneConfidenceController.text = val.toStringAsFixed(2);
              });
            },
            onInputChanged: (val) {
              final parsed = double.tryParse(val);
              if (parsed != null && parsed >= 0.0 && parsed <= 1.0) {
                setState(() {
                  noDroneConfidenceThreshold = parsed;
                });
              }
            },
          ),
          _buildSliderWithInput(
            label: 'Alert threshold',
            value: alertThreshold,
            min: 0.0,
            max: 1.0,
            controller: alertThresholdController,
            decimals: 2,
            onChanged: (val) {
              setState(() {
                alertThreshold = val;
                alertThresholdController.text = val.toStringAsFixed(2);
              });
            },
            onInputChanged: (val) {
              final parsed = double.tryParse(val);
              if (parsed != null && parsed >= 0.0 && parsed <= 1.0) {
                setState(() {
                  alertThreshold = parsed;
                });
              }
            },
          ),
          _buildSliderWithInput(
            label: 'Recognition frequency (times/sec)',
            value: recognitionFrequency,
            min: 1.0,
            max: 30.0,
            controller: recognitionFrequencyController,
            decimals: 1,
            onChanged: (val) {
              setState(() {
                recognitionFrequency = val;
                recognitionFrequencyController.text = val.toStringAsFixed(1);
              });
            },
            onInputChanged: (val) {
              final parsed = double.tryParse(val);
              if (parsed != null && parsed >= 1.0 && parsed <= 30.0) {
                setState(() {
                  recognitionFrequency = parsed;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            label: 'Recognition model selection',
            value: recognitionModel,
            items: recognitionModels,
            onChanged: (val) => setState(() => recognitionModel = val!),
          ),
          const Divider(height: 32),

          // App Settings Section
          const Text(
            'App Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Work in background'),
            value: workInBackground,
            onChanged: (val) => setState(() => workInBackground = val),
          ),
          const Divider(height: 32),

          // API for Alerts Section
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
