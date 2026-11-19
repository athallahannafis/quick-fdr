import 'package:flutter/material.dart';

/// RC Telemetry inspired dark theme with a deep navy palette and racing cyan accents.
class RcTheme {
  static const Color backgroundNavy = Color(0xFF0B132B);
  static const Color surfaceNavy = Color(0xFF1C2541);
  static const Color elevatedNavy = Color(0xFF222F55);
  static const Color borderNavy = Color(0xFF2C3E6B);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color electricBlue = Color(0xFF3A86FF);
  static const Color lockedGold = Color(0xFFFFB703);
  static const Color dangerRed = Color(0xFFEF233C);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8D99AE);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundNavy,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        onPrimary: backgroundNavy,
        secondary: electricBlue,
        onSecondary: textWhite,
        surface: surfaceNavy,
        onSurface: textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundNavy,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceNavy,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricBlue,
          foregroundColor: textWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
