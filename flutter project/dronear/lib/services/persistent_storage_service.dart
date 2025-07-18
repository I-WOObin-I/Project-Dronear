import 'package:shared_preferences/shared_preferences.dart';

class PersistentStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool?> getBool(String key) async => _prefs.getBool(key);
  Future<void> setBool(String key, bool value) async =>
      _prefs.setBool(key, value);
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);
}
