import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitstracker/core/theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePreferenceKey = 'theme_mode';
  SharedPreferences? _prefs;
  late ThemeMode _themeMode;

  ThemeProvider(this._prefs) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  ThemeData get theme =>
      _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;

  void updatePreferences(SharedPreferences prefs) {
    _prefs = prefs;
    _loadThemeMode();
  }

  void _loadThemeMode() {
    try {
      final savedThemeMode = _prefs?.getString(_themePreferenceKey);
      _themeMode = savedThemeMode == 'dark'
          ? ThemeMode.dark
          : savedThemeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.system;
    } catch (e) {
      // If there's any error, default to system theme
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      await _prefs?.setString(
        _themePreferenceKey,
        mode == ThemeMode.dark
            ? 'dark'
            : mode == ThemeMode.light
                ? 'light'
                : 'system',
      );
      notifyListeners();
    } catch (e) {
      // If there's any error, just update the theme mode in memory
      _themeMode = mode;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
