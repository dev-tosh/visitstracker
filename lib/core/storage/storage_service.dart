import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Theme related methods
  Future<void> setThemeMode(bool isDarkMode) async {
    await _prefs.setBool(_themeKey, isDarkMode);
  }

  bool? getThemeMode() {
    return _prefs.getBool(_themeKey);
  }

  // Generic methods for future use
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
