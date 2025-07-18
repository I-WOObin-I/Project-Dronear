import 'package:flutter/foundation.dart';
import '../services/persistent_storage_service.dart';

class AlertsState with ChangeNotifier {
  final PersistentStorageService _storage = PersistentStorageService();

  static const Map<String, bool> _defaultValues = {
    'is_call_alert_enabled': false,
    'is_sms_alert_enabled': false,
    'is_email_alert_enabled': false,
    'is_http_api_alert_enabled': false,
  };

  final Map<String, bool> _currentValues = {};

  Future<void> init() async {
    await _storage.init();

    for (final entry in _defaultValues.entries) {
      final key = entry.key;
      final defaultValue = entry.value;

      final bool exists = await _storage.containsKey(key);
      bool value;

      if (exists) {
        final storedValue = await _storage.getBool(key);
        value = storedValue ?? defaultValue;
      } else {
        value = defaultValue;
        await _storage.setBool(key, defaultValue);
      }

      if (!exists) await _storage.setBool(key, defaultValue);
      _currentValues[key] = value;
    }

    notifyListeners();
  }

  // General getter
  bool getValue(String key) => _currentValues[key] ?? false;

  // General setter
  Future<void> setValue(String key, bool value) async {
    _currentValues[key] = value;
    await _storage.setBool(key, value);
    notifyListeners();
  }

  // Convenience accessors
  bool get isCallEnabled => getValue(_defaultValues.keys.toList()[0]);
  bool get isSmsEnabled => getValue(_defaultValues.keys.toList()[1]);
  bool get isEmailEnabled => getValue(_defaultValues.keys.toList()[2]);
  bool get isHttpApiEnabled => getValue(_defaultValues.keys.toList()[3]);

  Future<void> toggleCall(bool value) =>
      setValue(_defaultValues.keys.toList()[0], value);
  Future<void> toggleSms(bool value) =>
      setValue(_defaultValues.keys.toList()[1], value);
  Future<void> toggleEmail(bool value) =>
      setValue(_defaultValues.keys.toList()[2], value);
  Future<void> toggleHttpApi(bool value) =>
      setValue(_defaultValues.keys.toList()[3], value);
}
