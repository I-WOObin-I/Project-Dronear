import 'package:flutter/foundation.dart';
import '../services/persistent_storage_service.dart';

class AlertsState with ChangeNotifier {
  final PersistentStorageService _storage = PersistentStorageService();

  static const String callAlertEnabledKey = 'call_alert_enabled';
  static const String callAlertTransmitSoundKey = 'call_alert_transmit_sound';
  static const String callAlertNumberKey = 'call_alert_number';
  static const String callAlertLastKey = 'call_alert_last';

  static const String smsAlertEnabledKey = 'sms_alert_enabled';
  static const String smsAlertIncludeLocationKey = 'sms_alert_include_location';
  static const String smsAlertIncludeSoundKey = 'sms_alert_include_sound';
  static const String smsAlertNumberKey = 'sms_alert_number';
  static const String smsAlertContentKey = 'sms_alert_content';
  static const String smsAlertLastKey = 'sms_alert_last';

  static const String emailAlertEnabledKey = 'email_alert_enabled';
  static const String emailAlertIncludeLocationKey = 'email_alert_include_location';
  static const String emailAlertIncludeSoundKey = 'email_alert_include_sound';
  static const String emailAlertAddressKey = 'email_alert_address';
  static const String emailAlertSubjectKey = 'email_alert_subject';
  static const String emailAlertPayloadKey = 'email_alert_payload';
  static const String emailAlertLastKey = 'email_alert_last';

  static const String httpApiAlertEnabledKey = 'http_api_alert_enabled';
  static const String httpApiAlertIncludeLocationKey = 'http_api_alert_include_location';
  static const String httpApiAlertIncludeSoundKey = 'http_api_alert_include_sound';
  static const String httpApiAlertUrlKey = 'http_api_alert_url';
  static const String httpApiAlertMethodKey = 'http_api_alert_method';
  static const String httpApiAlertHeadersKey = 'http_api_alert_headers';
  static const String httpApiAlertMessageKey = 'http_api_alert_message';
  static const String httpApiAlertLastKey = 'http_api_alert_last';

  static const Map<String, bool> _defaultValues = {
    callAlertEnabledKey: false,
    callAlertTransmitSoundKey: false,
    smsAlertEnabledKey: false,
    smsAlertIncludeLocationKey: false,
    smsAlertIncludeSoundKey: false,
    emailAlertEnabledKey: false,
    emailAlertIncludeLocationKey: false,
    emailAlertIncludeSoundKey: false,
    httpApiAlertEnabledKey: false,
    httpApiAlertIncludeLocationKey: false,
    httpApiAlertIncludeSoundKey: false,
  };

  static const Map<String, String> _defaultFields = {
    callAlertNumberKey: '',
    callAlertLastKey: '',
    smsAlertNumberKey: '',
    smsAlertContentKey: 'Drone detected!',
    smsAlertLastKey: '',
    emailAlertAddressKey: '',
    emailAlertSubjectKey: 'Drone Alert',
    emailAlertPayloadKey: 'A drone has been detected.',
    httpApiAlertUrlKey: '',
    httpApiAlertMethodKey: 'POST',
    httpApiAlertHeadersKey: '{}',
    httpApiAlertMessageKey: '{}',
  };

  final Map<String, bool> _currentValues = {};
  final Map<String, String> _currentFields = {};

  Future<void> init() async {
    await _storage.init();

    for (final entry in _defaultValues.entries) {
      final key = entry.key;
      final defaultValue = entry.value;

      final bool exists = await _storage.containsKey(key);

      if (exists) {
        final storedValue = await _storage.getBool(key);
        _currentValues[key] = storedValue ?? defaultValue;
      } else {
        _currentValues[key] = defaultValue;
        await _storage.createBool(key, defaultValue);
      }
    }

    for (final entry in _defaultFields.entries) {
      final key = entry.key;
      final defaultValue = entry.value;

      final bool exists = await _storage.containsKey(key);

      if (exists) {
        final storedValue = await _storage.getString(key);
        _currentFields[key] = storedValue ?? defaultValue;
      } else {
        _currentFields[key] = defaultValue;
        await _storage.createString(key, defaultValue);
      }
    }

    notifyListeners();
  }

  // General getter
  bool getValue(String key) => _currentValues[key] ?? false;
  String getField(String key) => _currentFields[key] ?? '';

  // General setter
  Future<void> setValue(String key, bool value) async {
    _currentValues[key] = value;
    await _storage.setBool(key, value);
    notifyListeners();
  }

  Future<void> setField(String key, String value) async {
    _currentFields[key] = value;
    await _storage.setString(key, value);
    notifyListeners();
  }
}
