import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // BetBoom Signature Brand Colors
  static const Color primary = Color(0xFFFFE600); // BetBoom Electric Yellow
  static const Color primaryDark = Color(0xFFE5CE00);
  static const Color secondary = Color(0xFFEA1B23); // BetBoom Signature Red
  static const Color accentRed = Color(0xFFEA1B23);
  static const Color accentYellow = Color(0xFFFFE600);
  static const Color accentGreen = Color(0xFF10B981); // Success / Win
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentGold = Color(0xFFFFD12E);
  static const Color accentOrange = Color(0xFFFF7A00);
  static const Color accentRose = Color(0xFFEA1B23);

  // BetBoom Deep Carbon Graphite Surfaces
  static const Color background = Color(0xFF101116); // Deep Carbon Graphite
  static const Color surface = Color(0xFF171922); // Dark Surface
  static const Color surfaceCard = Color(0xFF1F222D); // Card Background
  static const Color surfaceBorder = Color(0xFF2D313F); // Border
  static const Color surfaceCardHighlight = Color(0xFF282C3A);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8F95A5);
  static const Color textMuted = Color(0xFF5E6473);

  // Box Shadows
  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: primary.withAlpha(45),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get redGlow => [
        BoxShadow(
          color: secondary.withAlpha(50),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: accentRose,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF101116),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
