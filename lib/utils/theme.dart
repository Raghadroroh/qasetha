import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF006A71);
  static const Color _lightPrimaryLight = Color(0xFF4ECDC4);
  static const Color _lightPrimaryDark = Color(0xFF004D54);
  static const Color _lightAccent = Color(0xFF7DD3FC);
  
  static const Color _lightSecondary = Color(0xFF006A71);
  static const Color _lightSecondaryLight = Color(0xFF4ECDC4);
  static const Color _lightSecondaryDark = Color(0xFF004D54);
  
  static const Color _lightBackgroundPrimary = Color(0xFFFAFAFA);
  static const Color _lightBackgroundSecondary = Color(0xFFF5F5F5);
  static const Color _lightBackgroundTertiary = Color(0xFFEEEEEE);
  static const Color _lightCard = Color(0xFFFFFFFF);
  
  static const Color _lightTextPrimary = Color(0xFF1E293B);
  static const Color _lightTextSecondary = Color(0xFF475569);
  static const Color _lightTextTertiary = Color(0xFF64748B);
  static const Color _lightTextAccent = Color(0xFF0F172A);
  
  static const Color _lightBorderLight = Color(0xFFE2E8F0);
  static const Color _lightBorderMedium = Color(0xFFCBD5E1);
  static const Color _lightBorderDark = Color(0xFF94A3B8);
  
  static const Color _lightStatusSuccess = Color(0xFF10B981);
  static const Color _lightStatusWarning = Color(0xFFF59E0B);
  static const Color _lightStatusError = Color(0xFFEF4444);
  static const Color _lightStatusInfo = Color(0xFF3B82F6);

  // Dark Theme Colors
  static const Color _darkPrimary = Color(0xFF4ECDC4);
  static const Color _darkPrimaryLight = Color(0xFF7DD3FC);
  static const Color _darkPrimaryDark = Color(0xFF2E8B8B);
  static const Color _darkAccent = Color(0xFF60A5FA);
  
  static const Color _darkSecondary = Color(0xFF93C5FD);
  static const Color _darkSecondaryLight = Color(0xFFDBEAFE);
  static const Color _darkSecondaryDark = Color(0xFF60A5FA);
  
  static const Color _darkBackgroundPrimary = Color(0xFF0F172A);
  static const Color _darkBackgroundSecondary = Color(0xFF1E293B);
  static const Color _darkBackgroundTertiary = Color(0xFF334155);
  static const Color _darkCard = Color(0xFF1E293B);
  
  static const Color _darkTextPrimary = Color(0xFFF8FAFC);
  static const Color _darkTextSecondary = Color(0xFFCBD5E1);
  static const Color _darkTextTertiary = Color(0xFF94A3B8);
  static const Color _darkTextAccent = Color(0xFFE2E8F0);
  
  static const Color _darkBorderLight = Color(0xFF334155);
  static const Color _darkBorderMedium = Color(0xFF475569);
  static const Color _darkBorderDark = Color(0xFF64748B);
  
  static const Color _darkStatusSuccess = Color(0xFF34D399);
  static const Color _darkStatusWarning = Color(0xFFFBBF24);
  static const Color _darkStatusError = Color(0xFFF87171);
  static const Color _darkStatusInfo = Color(0xFF60A5FA);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        surface: _lightCard,
        background: _lightBackgroundPrimary,
        error: _lightStatusError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextPrimary,
        onBackground: _lightTextPrimary,
        onError: Colors.white,
      ),
      
      // Typography
      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        displayLarge: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.tajawal(color: _lightTextSecondary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.tajawal(color: _lightTextPrimary),
        bodyMedium: GoogleFonts.tajawal(color: _lightTextSecondary),
        bodySmall: GoogleFonts.tajawal(color: _lightTextTertiary),
        labelLarge: GoogleFonts.tajawal(color: _lightTextPrimary, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.tajawal(color: _lightTextSecondary),
        labelSmall: GoogleFonts.tajawal(color: _lightTextTertiary),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightCard,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.tajawal(
          color: _lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 8,
        shadowColor: _lightPrimary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _lightPrimary.withOpacity(0.3), width: 2),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shadowColor: _lightPrimary.withOpacity(0.6),
          elevation: 12,
        ).copyWith(
          overlayColor: MaterialStateProperty.all(_lightPrimary.withOpacity(0.2)),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightBackgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightBorderMedium.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightBorderLight.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
          gapPadding: 4,
        ),
        labelStyle: GoogleFonts.tajawal(color: _lightTextSecondary),
        hintStyle: GoogleFonts.tajawal(color: _lightTextTertiary),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        surface: _darkCard,
        background: _darkBackgroundPrimary,
        error: _darkStatusError,
        onPrimary: _darkTextAccent,
        onSecondary: _darkTextAccent,
        onSurface: _darkTextPrimary,
        onBackground: _darkTextPrimary,
        onError: _darkTextAccent,
      ),
      
      // Typography
      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        displayLarge: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.tajawal(color: _darkTextSecondary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.tajawal(color: _darkTextPrimary),
        bodyMedium: GoogleFonts.tajawal(color: _darkTextSecondary),
        bodySmall: GoogleFonts.tajawal(color: _darkTextTertiary),
        labelLarge: GoogleFonts.tajawal(color: _darkTextPrimary, fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.tajawal(color: _darkTextSecondary),
        labelSmall: GoogleFonts.tajawal(color: _darkTextTertiary),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkCard,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.tajawal(
          color: _darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 8,
        shadowColor: _darkPrimary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _darkPrimary.withOpacity(0.2), width: 1),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkTextAccent,
          textStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shadowColor: _darkPrimary.withOpacity(0.6),
          elevation: 12,
        ).copyWith(
          overlayColor: MaterialStateProperty.all(_darkPrimary.withOpacity(0.2)),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkBackgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkBorderMedium.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkBorderLight.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
          gapPadding: 4,
        ),
        labelStyle: GoogleFonts.tajawal(color: _darkTextSecondary),
        hintStyle: GoogleFonts.tajawal(color: _darkTextTertiary),
      ),
    );
  }

  // Custom Colors Extension
  static const AppColors lightColors = AppColors(
    primary: _lightPrimary,
    primaryLight: _lightPrimaryLight,
    primaryDark: _lightPrimaryDark,
    accent: _lightAccent,
    secondary: _lightSecondary,
    secondaryLight: _lightSecondaryLight,
    secondaryDark: _lightSecondaryDark,
    backgroundPrimary: _lightBackgroundPrimary,
    backgroundSecondary: _lightBackgroundSecondary,
    backgroundTertiary: _lightBackgroundTertiary,
    card: _lightCard,
    textPrimary: _lightTextPrimary,
    textSecondary: _lightTextSecondary,
    textTertiary: _lightTextTertiary,
    textAccent: _lightTextAccent,
    borderLight: _lightBorderLight,
    borderMedium: _lightBorderMedium,
    borderDark: _lightBorderDark,
    statusSuccess: _lightStatusSuccess,
    statusWarning: _lightStatusWarning,
    statusError: _lightStatusError,
    statusInfo: _lightStatusInfo,
  );

  static const AppColors darkColors = AppColors(
    primary: _darkPrimary,
    primaryLight: _darkPrimaryLight,
    primaryDark: _darkPrimaryDark,
    accent: _darkAccent,
    secondary: _darkSecondary,
    secondaryLight: _darkSecondaryLight,
    secondaryDark: _darkSecondaryDark,
    backgroundPrimary: _darkBackgroundPrimary,
    backgroundSecondary: _darkBackgroundSecondary,
    backgroundTertiary: _darkBackgroundTertiary,
    card: _darkCard,
    textPrimary: _darkTextPrimary,
    textSecondary: _darkTextSecondary,
    textTertiary: _darkTextTertiary,
    textAccent: _darkTextAccent,
    borderLight: _darkBorderLight,
    borderMedium: _darkBorderMedium,
    borderDark: _darkBorderDark,
    statusSuccess: _darkStatusSuccess,
    statusWarning: _darkStatusWarning,
    statusError: _darkStatusError,
    statusInfo: _darkStatusInfo,
  );
}

class AppColors {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textAccent,
    required this.borderLight,
    required this.borderMedium,
    required this.borderDark,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusError,
    required this.statusInfo,
  });

  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textAccent;
  final Color borderLight;
  final Color borderMedium;
  final Color borderDark;
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusError;
  final Color statusInfo;
}

// Extension للوصول السهل للألوان
extension AppColorsExtension on BuildContext {
  AppColors get colors {
    return Theme.of(this).brightness == Brightness.light
        ? AppTheme.lightColors
        : AppTheme.darkColors;
  }
}