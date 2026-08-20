import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static bool _dark = true;
  static void setDark(bool v) => _dark = v;

  static const signal = Color(0xFFFFB020);
  static const signalDim = Color(0xFF6B4E1A);
  static const success = Color(0xFF3FCF8E);
  static const danger = Color(0xFFF06B6B);
  static const info = Color(0xFF5B9DFF);

  static Color get bg =>
      _dark ? const Color(0xFF0B0D12) : const Color(0xFFF5F6F8);
  static Color get surface =>
      _dark ? const Color(0xFF141821) : const Color(0xFFFFFFFF);
  static Color get surfaceAlt =>
      _dark ? const Color(0xFF1B2029) : const Color(0xFFEDEFF3);
  static Color get line =>
      _dark ? const Color(0xFF262C38) : const Color(0xFFE2E5EB);
  static Color get text =>
      _dark ? const Color(0xFFF4F6FA) : const Color(0xFF14171F);
  static Color get textDim =>
      _dark ? const Color(0xFF8A93A6) : const Color(0xFF5A6272);
  static Color get textFaint =>
      _dark ? const Color(0xFF5A6272) : const Color(0xFF9AA1AE);
}

class AppTheme {
  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    AppColors.setDark(isDark);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.signal,
        brightness: brightness,
        primary: AppColors.signal,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.signal,
          foregroundColor: const Color(0xFF1A1206),
          disabledBackgroundColor: AppColors.signalDim,
          disabledForegroundColor: AppColors.textFaint,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.signal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: TextStyle(color: AppColors.textFaint, fontSize: 15),
        labelStyle: TextStyle(color: AppColors.textDim),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.signal, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.danger),
        ),
      ),
    );
  }

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);
}
