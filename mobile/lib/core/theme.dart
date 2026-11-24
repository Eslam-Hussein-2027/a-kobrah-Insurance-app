import 'package:flutter/material.dart';

/// Brand palette: navy from the company logo on a warm off-white ground.
/// Flat colours only (no gradients); borders do the separation work.
class AppColors {
  const AppColors._();

  static const navy = Color(0xFF14178F);
  static const navyTint = Color(0xFFECEDF6);
  static const blue = Color(0xFF0A7FD4);
  static const ink = Color(0xFF0F1530);
  static const background = Color(0xFFF5F5F1);
  static const border = Color(0xFFE6E4DC);
  static const fieldBorder = Color(0xFFD9D7CE);
  static const muted = Color(0xFF6B6F80);
  static const subtle = Color(0xFF8A8D9A);

  static const success = Color(0xFF127A4F);
  static const successTint = Color(0xFFE4F1EA);
  static const warning = Color(0xFFA6560B);
  static const warningTint = Color(0xFFF8EBDA);
  static const notice = Color(0xFFFAF1E4);
  static const noticeBorder = Color(0xFFEEDCBF);
  static const info = Color(0xFF1F4E8C);
  static const infoTint = Color(0xFFE5ECF7);
  static const neutralTint = Color(0xFFECEBE6);
  static const danger = Color(0xFFB3261E);
}

class AppTheme {
  const AppTheme._();

  static const fontFamily = 'IBMPlexSansArabic';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
      secondary: AppColors.blue,
      surface: Colors.white,
      onSurface: AppColors.ink,
      error: AppColors.danger,
    );

    final fieldRadius = BorderRadius.circular(12);
    final buttonRadius = BorderRadius.circular(14);
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: fontFamily);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        labelStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: const BorderSide(color: AppColors.navy, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(50),
          side: const BorderSide(color: AppColors.fieldBorder),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white, showDragHandle: true),
    );
  }
}
