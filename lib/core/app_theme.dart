import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors matching Campus Fix
  static const Color primaryNavy = Color(0xFF10355B);
  static const Color navyDark = Color(0xFF0A1F36);
  static const Color navyLight = Color(0xFF1E40AF);
  static const Color sidebarBg = Color(0xFF0B192C);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF334155);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textSubtle = Color(0xFF94A3B8);

  static const Color accentTeal = Color(0xFF0D9488);
  static const Color accentTealBg = Color(0xFFE6FFFA);

  // Status & Severity Colors
  static const Color openBg = Color(0xFFEFF6FF);
  static const Color openText = Color(0xFF1D4ED8);

  static const Color inProgressBg = Color(0xFFFEF3C7);
  static const Color inProgressText = Color(0xFFD97706);

  static const Color resolvedBg = Color(0xFFECFDF5);
  static const Color resolvedText = Color(0xFF059669);

  static const Color assignedBg = Color(0xFFFFEDD5);
  static const Color assignedText = Color(0xFFC2410C);

  static const Color rejectedBg = Color(0xFFFEE2E2);
  static const Color rejectedText = Color(0xFFDC2626);

  // Priority Colors
  static const Color priorityLowBg = Color(0xFFF1F5F9);
  static const Color priorityLowText = Color(0xFF475569);

  static const Color priorityMedBg = Color(0xFFE0F2FE);
  static const Color priorityMedText = Color(0xFF0284C7);

  static const Color priorityHighBg = Color(0xFFFFEDD5);
  static const Color priorityHighText = Color(0xFFEA580C);

  static const Color priorityUrgentBg = Color(0xFFFEE2E2);
  static const Color priorityUrgentText = Color(0xFFE11D48);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        primary: primaryNavy,
        secondary: accentTeal,
        surface: cardBg,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.inter(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: GoogleFonts.inter(
          color: textDark,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.inter(
          color: textDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.inter(
          color: textDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textMedium,
          fontSize: 15,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: textSubtle,
          fontSize: 12,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryNavy, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textSubtle),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
