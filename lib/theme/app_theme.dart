import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF0a1628);       // Deep Harmonia blue
  static const Color navyLight = Color(0xFF1a2744);  // Lighter navy
  static const Color accent = Color(0xFF4a9eff);      // Bright blue from logo
  static const Color accentLight = Color(0xFF7bb8ff); // Lighter blue
  static const Color sage = Color(0xFF7db89a);
  static const Color cream = Color(0xFFf8f6f1);
  static const Color gray = Color(0xFFe8e4dc);
  static const Color grayDark = Color(0xFFc5bfb2);
  static const Color text = Color(0xFF2c2c2c);
  static const Color textMuted = Color(0xFF777777);
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFe53e3e);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        primary: AppColors.accent,
        secondary: AppColors.sage,
        surface: AppColors.white,
        background: AppColors.cream,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.text,
        onBackground: AppColors.text,
        error: AppColors.error,
      ),
      fontFamily: 'Nunito',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, color: AppColors.navy),
        displayMedium: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, color: AppColors.navy),
        titleLarge: TextStyle(fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.w700, color: AppColors.navy),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: AppColors.text),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: AppColors.text),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: const Color(0x1A0a1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.white,
      ),
    );
  }
}
