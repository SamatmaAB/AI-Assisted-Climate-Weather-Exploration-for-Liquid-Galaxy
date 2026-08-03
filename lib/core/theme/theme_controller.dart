import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton [ChangeNotifier] that owns the app-wide theme state.
///
/// [MaterialApp] listens to this and rebuilds when [themeMode] or
/// [isColorblindMode] changes. The [SettingsViewModel] calls [setDarkMode]
/// and [setColorblindMode] so the UI reacts immediately.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  ThemeMode _themeMode = ThemeMode.dark;
  bool _isColorblindMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isColorblindMode => _isColorblindMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Call once at startup to restore persisted preferences.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final darkMode = prefs.getBool('isDarkMode') ?? true;
    _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    _isColorblindMode = prefs.getBool('isColorblindMode') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> setColorblindMode(bool value) async {
    _isColorblindMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isColorblindMode', value);
  }
}
