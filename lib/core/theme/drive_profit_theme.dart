import 'package:flutter/material.dart';

class DriveProfitTheme {
  static const Color primaryColor = Color(0xFF16724C);
  static const Color secondaryColor = Color(0xFF246B86);
  static const Color backgroundColor = Color(0xFFF0F4F1);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardTintColor = Color(0xFFE3F2E9);
  static const Color profitColor = Color(0xFF16724C);
  static const Color lossColor = Color(0xFFC45151);
  static const Color warningColor = Color(0xFFD39B2D);
  static const Color titleColor = Color(0xFF15231D);
  static const Color subtitleColor = Color(0xFF65736B);
  static const Color borderColor = Color(0xFFD8E0DA);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      surface: cardColor,
    ).copyWith(secondary: secondaryColor, error: lossColor);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: titleColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: titleColor,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: titleColor,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
        bodyLarge: const TextStyle(fontSize: 16, color: titleColor),
        bodyMedium: const TextStyle(fontSize: 14, color: subtitleColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: const TextStyle(color: subtitleColor),
        labelStyle: const TextStyle(
          color: subtitleColor,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: const TextStyle(color: subtitleColor, fontSize: 12),
        errorStyle: const TextStyle(
          color: lossColor,
          fontWeight: FontWeight.w600,
        ),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lossColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lossColor, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: borderColor),
          shape: RoundedRectangleBorder
