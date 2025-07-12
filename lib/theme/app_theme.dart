import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Mode Colors - متناسقة وعصرية
  static const Color _lightPrimary = Color(0xFF2E7D8A);
  static const Color _lightSecondary = Color(0xFF4A9FB0);
  static const Color _lightTertiary = Color(0xFF7BC4D1);
  static const Color _lightSurface = Color(0xFFF8FAFB);
  static const Color _lightBackground = Color(0xFFFFFFFF);

  // Dark Mode Colors - متناسقة مع الفاتح
  static const Color _darkPrimary = Color(0xFF4DD0E1);
  static const Color _darkSecondary = Color(0xFF26C6DA);
  static const Color _darkTertiary = Color(0xFF80DEEA);
  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkBackground = Color(0xFF121212);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      tertiary: _lightTertiary,
      surface: _lightSurface,
      background: _lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: const Color(0xFF1A1C1E),
      onBackground: const Color(0xFF1A1C1E),
    ),
    fontFamily: GoogleFonts.tajawal().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF1A1C1E)),
      titleTextStyle: GoogleFonts.tajawal(
        color: const Color(0xFF1A1C1E),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      tertiary: _darkTertiary,
      surface: _darkSurface,
      background: _darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),
    fontFamily: GoogleFonts.tajawal().fontFamily,
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.tajawal(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Gradient helpers
  static LinearGradient get lightGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_lightPrimary, _lightSecondary, _lightTertiary],
  );

  static LinearGradient get darkGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkBackground, _darkSurface, _darkPrimary],
  );
}