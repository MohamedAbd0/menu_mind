import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A73E8);
  static const Color accent = Color(0xFFFBBC05);
  static const Color textPrimary = Color(0xFF202124);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD93025);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF34A853);

  // Card colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);

  // Text colors
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textDisabled = Color(0xFF9AA0A6);

  // Chip colors
  static const Color chipVegetarian = Color(0xFF4CAF50);
  static const Color chipHalal = Color(0xFF2196F3);
  static const Color chipSpicy = Color(0xFFFF5722);
  static const Color chipSeafood = Color(0xFF00BCD4);
  static const Color chipAllergen = Color(0xFFD32F2F);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF4285F4)],
  );
}
