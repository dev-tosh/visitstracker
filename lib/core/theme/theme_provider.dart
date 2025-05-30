import 'package:flutter/material.dart';
import 'package:visitstracker/core/storage/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storage;
  bool _isDarkMode;

  ThemeProvider(this._storage) : _isDarkMode = _storage.getThemeMode() ?? false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  static final _lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  static final _darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
