import 'package:flutter/material.dart';

class AppTheme {
  // ПАЛИТРА ПО ТЗ (BB / Betboom):
  // • #F5F1E9 — основной светлый фон.
  // • #F1F3F2 — фон информационных блоков.
  // • #FFFFFF — светлые карточки.
  // • #F5F500 — основной ярко-жёлтый акцент: кнопки, активные вкладки, шкалы прогресса.
  // • #191919 — фон тёмных карточек и нижней навигации.
  // • #292929 — дополнительные тёмные поверхности.
  // • #202320 — основной текст на светлом фоне.
  // • #FFFFFF — текст на тёмных карточках.
  // • #686D69 — второстепенные подписи на светлом фоне.
  // • #BFC3BF — второстепенные подписи на тёмном фоне.
  // • #DDE1DD — разделители и контуры.
  // На жёлтых кнопках использовать текст #191919.

  static const Color background = Color(0xFFF5F1E9);
  static const Color surfaceBlock = Color(0xFFF1F3F2);
  static const Color surfaceLightCard = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFF5F500); // Ярко-жёлтый
  static const Color darkCard = Color(0xFF191919); // Тёмные карточки и нижняя навигация
  static const Color darkSurface = Color(0xFF292929);
  static const Color textDark = Color(0xFF202320);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF686D69);
  static const Color textMutedDark = Color(0xFFBFC3BF);
  static const Color border = Color(0xFFDDE1DD);
  static const Color onPrimary = Color(0xFF191919);

  // Семантические алиасы
  static const Color surface = surfaceLightCard;
  static const Color surfaceCard = surfaceLightCard;
  static const Color surfaceBorder = border;
  static const Color surfaceCardHighlight = surfaceBlock;
  static const Color textPrimary = textDark;
  static const Color secondary = darkCard;
  static const Color accentYellow = primary;
  static const Color accentGold = primary;
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRose = Color(0xFFEA1B23);
  static const Color accentRed = Color(0xFFEA1B23);
  static const Color accentPurple = Color(0xFFA855F7);
  static const Color accentOrange = Color(0xFFFF7A00);
  static const Color textMuted = textSecondary;

  static const double cardRadius = 20.0;
  static const double buttonRadius = 12.0;
  static const double screenPadding = 16.0;
  static const double buttonHeight = 48.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get darkCardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: primary.withAlpha(80),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get redGlow => neonGlow;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: darkCard,
        surface: surfaceLightCard,
        error: accentRose,
        onPrimary: onPrimary,
        onSurface: textDark,
      ),
      fontFamily: null, // Системный шрифт
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textDark),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(0, buttonHeight),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          elevation: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark),
        iconTheme: IconThemeData(color: textDark),
      ),
    );
  }

  // Для совместимости
  static ThemeData get darkTheme => lightTheme;
}
