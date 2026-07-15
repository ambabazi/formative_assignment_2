import 'package:flutter/material.dart';

class AluColors {
  static const navy = Color(0xFF00234B);
  static const red = Color(0xFFC61D23);
  static const white = Color(0xFFFFFFFF);
  static const lightGrey = Color(0xFFB0B8C1);
  static const cardDark = Color(0xFF0D2E4F);
  static const surface = Color(0xFFF5F7FA);
}

ThemeData buildAluTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AluColors.surface,
    colorScheme: const ColorScheme.light(
      primary: AluColors.navy,
      onPrimary: AluColors.white,
      secondary: AluColors.red,
      onSecondary: AluColors.white,
      surface: AluColors.white,
      onSurface: AluColors.navy,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AluColors.navy,
      foregroundColor: AluColors.white,
      elevation: 0,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AluColors.red,
        foregroundColor: AluColors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AluColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: AluColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AluColors.navy.withValues(alpha: 0.08),
      labelStyle: const TextStyle(color: AluColors.navy, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
