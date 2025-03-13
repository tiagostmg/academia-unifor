import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primaryLight,
      onPrimary: Colors.black,
      secondary: AppColors.secondaryLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: colorScheme.onSurface),
        bodyMedium: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primaryDark,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: colorScheme.onSurface),
        bodyMedium: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
    );
  }
}
