import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: Colors.lime.shade600,
        onPrimary: Colors.white,
        secondary: Colors.lime.shade400,
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
        primary: Colors.lime.shade300,
        onPrimary: Colors.black,
        secondary: Colors.lime.shade200,
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
    backgroundColor: Colors.lime,
    foregroundColor: Colors.black,
    elevation: 1,
  );
}
