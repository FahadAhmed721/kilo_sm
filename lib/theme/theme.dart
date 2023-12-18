import 'package:flutter/material.dart';
import 'package:kiloi_sm/utils/app_colors.dart';

class AppTheme {
  AppTheme._();
  static ThemeData appTheme = ThemeData(
      scaffoldBackgroundColor: AppColors.mainBGColor,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.mainBGColor));
}
