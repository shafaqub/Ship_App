import 'package:flutter/material.dart';

class AppTheme {
  // Main colors
  static const Color background = Color(0xFF071426);
  static const Color cardBackground = Color(0xFF0D1D34);

  static const Color purple = Color(0xFF8B5CF6);
  static const Color lightBlue = Color(0xFF63C5F2);

  static const Color primaryText = Color(0xFFF5F7FF);
  static const Color secondaryText = Color(0xFF9BA9C2);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: lightBlue,
      secondary: purple,
      surface: cardBackground,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: primaryText,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primaryText,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),

      headlineMedium: TextStyle(
        color: primaryText,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),

      titleLarge: TextStyle(
        color: primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(color: primaryText, fontSize: 16),

      bodyMedium: TextStyle(color: secondaryText, fontSize: 14),
    ),
  );
}
