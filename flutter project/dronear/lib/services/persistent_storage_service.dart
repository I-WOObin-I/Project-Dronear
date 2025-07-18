import 'package:shared_preferences/shared_preferences.dart';

class PersistentStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> containsKey(String key) async => _prefs.containsKey(key);

  Future<void> createBool(String key, bool value) async {
    if (_prefs.containsKey(key)) {
      throw Exception('Key already exists: $key');
    }
    _prefs.setBool(key, value);
  }

  Future<void> createString(String key, String value) async {
    if (_prefs.containsKey(key)) {
      throw Exception('Key already exists: $key');
    }
    _prefs.setString(key, value);
  }

  Future<bool?> getBool(String key) async => _prefs.getBool(key);
  Future<String?> getString(String key) async => _prefs.getString(key);

  Future<void> setBool(String key, bool value) async {
    if (_prefs.containsKey(key)) {
      _prefs.setBool(key, value);
    } else {
      throw Exception('Key does not exist: $key');
    }
  }

  Future<void> setString(String key, String value) async {
    if (_prefs.containsKey(key)) {
      _prefs.setString(key, value);
    } else {
      throw Exception('Key does not exist: $key');
    }
  }
}
