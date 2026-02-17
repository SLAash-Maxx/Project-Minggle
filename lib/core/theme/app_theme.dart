import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryRose,
    scaffoldBackgroundColor: AppColors.backgroundBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundBlack,
      elevation: 0,
    ),
    // Text styles focus on Poppins font as per your guide
    fontFamily: 'Poppins',
  );
}
