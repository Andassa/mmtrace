import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Charte BCMM mobile (alignée web) : plat, lisible, sans ombre.
class Bcmm {
  static const primary = Color(0xFF1B4F8A);
  static const primarySoft = Color(0xFFE8F0F8);
  static const canvas = Color(0xFFF4F6F9);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const title = Color(0xFF0F172A);
  static const body = Color(0xFF334155);
  static const muted = Color(0xFF64748B);
  static const danger = Color(0xFFB91C1C);
  static const success = Color(0xFF15803D);

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: card,
      ),
      scaffoldBackgroundColor: canvas,
      dividerColor: border,
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        foregroundColor: title,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: title,
        ),
        shape: const Border(bottom: BorderSide(color: border)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: GoogleFonts.ibmPlexSansTextTheme().apply(
        bodyColor: body,
        displayColor: title,
      ),
    );
    return base;
  }
}
