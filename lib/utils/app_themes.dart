import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00E5FF),
      secondary: Color(0xFF0099CC),
      tertiary: Color(0xFF6A5ACD),
      surface: Color(0xFFFAFAFA),
      background: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
      onBackground: Color(0xFF1A1A1A),
    ),
    textTheme: GoogleFonts.tajawalTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00E5FF),
      secondary: Color(0xFF0099CC),
      tertiary: Color(0xFF6A5ACD),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onSurface: Color(0xFFE0E0E0),
      onBackground: Color(0xFFE0E0E0),
    ),
    textTheme: GoogleFonts.tajawalTextTheme(ThemeData.dark().textTheme),
  );

  static List<Color> getGradientColors(BuildContext context, bool isDark) {
    return isDark ? [
      const Color(0xFF0A0E21),
      const Color(0xFF1A1B3A),
      const Color(0xFF2D1B69),
      const Color(0xFF0A192F),
    ] : [
      const Color(0xFF87CEEB),
      const Color(0xFF4682B4),
      const Color(0xFF6495ED),
      const Color(0xFF00BFFF),
    ];
  }
}