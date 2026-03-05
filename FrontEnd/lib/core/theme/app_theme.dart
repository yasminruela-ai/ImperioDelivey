import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFD32F2F);
  static const Color secondary = Color(0xFFFFC107);
  static const Color background = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

 static ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    secondary: secondary,
    onPrimary: Colors.white,          // 🔑 TEXTO EM BOTÕES
    onSecondary: Colors.black,
    onBackground: textPrimary,
    onSurface: textPrimary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: textPrimary),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: textPrimary),
    bodyMedium: TextStyle(color: textSecondary),
    titleLarge: TextStyle(
      color: textPrimary,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 6,
    shadowColor: Colors.black.withValues(alpha: 0.15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    ),
  ),
);
}