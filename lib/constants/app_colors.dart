import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00E5FF);
  static const Color primaryDark = Color(0xFF0099CC);
  static const Color secondary = Color(0xFF00BCD4);
  static const Color accent = Color(0xFF40E0D0);

  static const Color backgroundDark1 = Color(0xFF0A0E21);
  static const Color backgroundDark2 = Color(0xFF1A1B3A);
  static const Color backgroundDark3 = Color(0xFF2D1B69);
  static const Color backgroundDark4 = Color(0xFF0A192F);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF607D8B);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      backgroundDark1,
      backgroundDark2,
      backgroundDark3,
      backgroundDark4,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static Color get whiteTransparent20 => Colors.white.withValues(alpha: 0.2);

  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      whiteTransparent20.withValues(alpha: 0.1),
      whiteTransparent20.withValues(alpha: 0.05),
    ],
  );
}
