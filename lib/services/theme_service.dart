import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _firstTimeKey = 'first_time_language';
  
  ThemeMode _themeMode = ThemeMode.dark; // افتراضي داكن
  String _languageCode = 'system'; // افتراضي لغة النظام
  bool _isFirstTimeLanguageSelection = true;

  ThemeMode get themeMode => _themeMode;
  String get languageCode => _getEffectiveLanguageCode();
  String get savedLanguageCode => _languageCode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  bool get isFirstTimeLanguageSelection => _isFirstTimeLanguageSelection;
  
  // الحصول على كود اللغة الفعلي
  String _getEffectiveLanguageCode() {
    if (_languageCode == 'system') {
      final systemLocale = PlatformDispatcher.instance.locale.languageCode;
      return ['ar', 'en'].contains(systemLocale) ? systemLocale : 'ar';
    }
    return _languageCode;
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex == null) {
      _themeMode = ThemeMode.dark; // افتراضي داكن
    } else {
      _themeMode = ThemeMode.values[themeIndex];
    }
    _languageCode = prefs.getString(_languageKey) ?? 'system'; // افتراضي لغة النظام
    _isFirstTimeLanguageSelection = prefs.getBool(_firstTimeKey) ?? true;
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
  
  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
    }
    notifyListeners();
    _saveThemeMode();
  }
  
  void toggleLanguage() {
    switch (_languageCode) {
      case 'ar':
        _languageCode = 'en';
        break;
      case 'en':
        _languageCode = 'system';
        break;
      case 'system':
        _languageCode = 'ar';
        break;
    }
    notifyListeners();
    _saveLanguage();
  }
  
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
  
  String getThemeName(String languageCode) {
    final isArabic = languageCode == 'ar';
    switch (_themeMode) {
      case ThemeMode.light:
        return isArabic ? 'فاتح' : 'Light';
      case ThemeMode.dark:
        return isArabic ? 'داكن' : 'Dark';
      case ThemeMode.system:
        return isArabic ? 'النظام' : 'System';
    }
  }
  
  String getLanguageName(String languageCode) {
    final isArabic = languageCode == 'ar';
    switch (_languageCode) {
      case 'ar':
        return isArabic ? 'العربية' : 'Arabic';
      case 'en':
        return isArabic ? 'الإنجليزية' : 'English';
      case 'system':
        return isArabic ? 'لغة النظام' : 'System Language';
      default:
        return isArabic ? 'غير محدد' : 'Unknown';
    }
  }
  
  void _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
  }
  
  void _saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _languageCode);
  }
  
  Future<void> setFirstTimeLanguageSelection(bool isFirstTime) async {
    _isFirstTimeLanguageSelection = isFirstTime;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, isFirstTime);
    notifyListeners();
  }
}