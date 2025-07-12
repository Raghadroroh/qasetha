import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'locale';
  Locale? _locale;

  Locale? get locale => _locale;

  bool get isArabic => _locale?.languageCode == 'ar';
  bool get isEnglish => _locale?.languageCode == 'en';
  bool get isSystemDefault => _locale == null;

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    } else {
      _locale = null; // System default
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString(_localeKey, locale.languageCode);
    } else {
      await prefs.remove(_localeKey);
    }
    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'System Default';
    }
  }
}