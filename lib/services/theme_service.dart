import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  
  ThemeMode _themeMode = ThemeMode.dark;
  String _languageCode = 'ar';

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex == null) {
      _themeMode = ThemeMode.dark; // افتراضي داكن
    } else {
      _themeMode = ThemeMode.values[themeIndex];
    }
    _languageCode = prefs.getString(_languageKey) ?? 'ar';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }
}