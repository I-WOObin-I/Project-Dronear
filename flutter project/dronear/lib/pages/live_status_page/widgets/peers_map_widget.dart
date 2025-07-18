import 'package:flutter/material.dart';
import '../../../config/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeersMapWidget extends StatefulWidget {
  const PeersMapWidget({super.key});

  @override
  State<PeersMapWidget> createState() => _PeersMapWidgetState();
}

class _PeersMapWidgetState extends State<PeersMapWidget> {
  Map<String, Object?> _prefsMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final Map<String, Object?> map = {};
    for (var key in keys) {
      map[key] = prefs.get(key);
    }

    setState(() {
      _prefsMap = map;
      _loading = false;
    });
  }

  // Call this whenever you update SharedPreferences somewhere in your app
  void _refresh() => _loadPrefs();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: AppTheme.cardSideMargin),
        padding: AppTheme.cardPadding,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.boxBorderColor),
          borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("peers map", style: TextStyle(fontSize: 18))),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _refresh, child: const Text('Refresh prefs')),
            const SizedBox(height: 2),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView(
                      children: _prefsMap.entries.map((entry) {
                        return Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 14),
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
