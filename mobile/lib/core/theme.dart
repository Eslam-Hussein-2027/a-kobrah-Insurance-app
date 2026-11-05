import 'package:flutter/material.dart';

/// Brand colours sampled from the company logo (navy text + blue gradient mark).
class AppColors {
  const AppColors._();

  static const navy = Color(0xFF14178F);
  static const blue = Color(0xFF0A7FD4);
  static const sky = Color(0xFF14A3E6);
  static const background = Color(0xFFF4F6FB);
  static const border = Color(0xFFE1E5EF);
  static const muted = Color(0xFF667085);

  static const success = Color(0xFF12805C);
  static const warning = Color(0xFFB54708);
  static const danger = Color(0xFFC0352B);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.blue,
      surface: Colors.white,
      error: AppColors.danger,
    );

    final radius = BorderRadius.circular(14);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Tajawal',
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blue.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: 'Tajawal', fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
