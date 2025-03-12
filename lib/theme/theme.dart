import 'package:flutter/material.dart';
import 'app_colors.dart'; // Importando a classe de cores

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: _appBarTheme,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.black,
        secondary: AppColors.secondary,
        surface: const Color(0xFF1C1C1E),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      appBarTheme: _appBarTheme,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.black,
    elevation: 1,
  );
}
