import 'package:flutter/material.dart';

/// Vanakkam Akka - App Color Palette
/// Warm, engaging colors specifically selected for rural health context
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFFE8930A); // Warm saffron
  static const Color secondary = Color(0xFF1A6B3A); // Deep green
  static const Color accent = Color(0xFFF5C518); // Turmeric

  // Backgrounds & Surfaces (No harsh whites)
  static const Color background = Color(0xFFFFF9F0); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);

  // Risk & Status Colors
  static const Color riskGreen = Color(0xFF2D7A3A);
  static const Color riskYellow = Color(0xFFC97B00);
  static const Color riskRed = Color(0xFFC0392B);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5A5A5A);
}
