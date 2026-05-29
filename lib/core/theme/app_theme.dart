import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF1A1A1A);
  static const Color primaryAction = Color(0xFF2C2C2C);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
    );
  }
}
