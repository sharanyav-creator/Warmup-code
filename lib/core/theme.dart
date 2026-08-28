import 'package:flutter/material.dart';

/// Placeholder theme — swap tokens here once Figma design specs are provided.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4C5FD5);
  static const Color background = Color(0xFFF7F7FB);
  static const Color surface = Colors.white;
  static const Color success = Color(0xFF2FA36B);
  static const Color warning = Color(0xFFE0A62E);
  static const Color danger = Color(0xFFD9534F);
  static const Color textPrimary = Color(0xFF1B1D28);
  static const Color textSecondary = Color(0xFF6B6E7B);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
