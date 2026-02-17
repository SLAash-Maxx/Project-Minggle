import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryRose = Color(0xFFFF6B9D);
  static const Color secondaryPurple = Color(0x8B5CF6FF);
  static const Color backgroundBlack = Color(0xFF1A1A1A);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Gradient for buttons and backgrounds
  static const LinearGradient roseToPurple = LinearGradient(
    colors: [primaryRose, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
