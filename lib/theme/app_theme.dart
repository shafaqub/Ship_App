import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // BACKGROUND / SURFACES
  // ============================================================

  static const Color midnightNavy = Color(0xFF0B0E17);
  static const Color deepNavy = Color(0xFF111827);
  static const Color cardSurface = Color(0xFF161F30);
  static const Color cardBorder = Color(0xFF233047);

  // ============================================================
  // ACCENT COLORS
  // ============================================================

  static const Color accentCyan = Color(0xFF38BDF8);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFFA855F7);

  static const Color glowingDot = Color(0xFF38BDF8);

  // ============================================================
  // TEXT COLORS
  // ============================================================

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ============================================================
  // GRADIENTS
  // ============================================================

  static const LinearGradient logoGradient = LinearGradient(
    colors: [
      accentCyan,
      accentBlue,
      accentPurple,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF070910),
      Color(0xFF0B0E17),
      Color(0xFF131A2B),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}


// ================================================================
// APP THEME
// ================================================================

class AppTheme {
  // ============================================================
  // COMPATIBILITY ALIASES
  //
  // These names are kept because some of your older screens use
  // AppTheme.background, AppTheme.cardBackground, etc.
  // ============================================================

  static const Color background = AppColors.midnightNavy;

  static const Color cardBackground = AppColors.cardSurface;

  static const Color purple = AppColors.accentPurple;

  static const Color lightBlue = AppColors.accentCyan;

  static const Color primaryText = AppColors.textPrimary;

  static const Color secondaryText = AppColors.textSecondary;

  // ============================================================
  // MAIN THEME
  // ============================================================

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // --------------------------------------------------------
      // GENERAL
      // --------------------------------------------------------

      scaffoldBackgroundColor: AppColors.midnightNavy,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCyan,
        secondary: AppColors.accentPurple,
        surface: AppColors.cardSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.midnightNavy,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      // --------------------------------------------------------
      // DRAWER
      // --------------------------------------------------------

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.deepNavy,
        surfaceTintColor: Colors.transparent,
      ),

      // --------------------------------------------------------
      // CARDS
      // --------------------------------------------------------

      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.cardBorder,
          ),
        ),
      ),

      // --------------------------------------------------------
      // INPUT FIELDS
      // --------------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.deepNavy.withValues(
          alpha: 0.8,
        ),

        hintStyle: const TextStyle(
          color: AppColors.textMuted,
        ),

        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),

        prefixIconColor: AppColors.accentCyan,

        suffixIconColor: AppColors.textSecondary,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.accentCyan,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),

      // --------------------------------------------------------
      // FILLED BUTTON
      // --------------------------------------------------------

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: AppColors.midnightNavy,

          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
        ),
      ),

      // --------------------------------------------------------
      // OUTLINED BUTTON
      // --------------------------------------------------------

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,

          side: const BorderSide(
            color: AppColors.accentCyan,
          ),

          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
        ),
      ),

      // --------------------------------------------------------
      // LIST TILES
      // --------------------------------------------------------

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),

      // --------------------------------------------------------
      // TEXT THEME
      // --------------------------------------------------------

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),

        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),

        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),

        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),

        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

        titleSmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),

        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),

        bodySmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),

        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        labelMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  // ============================================================
  // BACKWARD COMPATIBILITY
  //
  // If your main.dart currently uses:
  //
  // theme: AppTheme.darkTheme
  //
  // it will still work.
  // ============================================================

  static ThemeData get darkTheme => theme;
}