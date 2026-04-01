import 'package:flutter/material.dart';

/// Vanakkam Akka - App Color Palette
/// Warm, engaging colors specifically selected for rural health context
class AppColors {
  AppColors._();

  // Primary palette — Modern-Rural (warm, trustworthy)
  static const Color primary = Color(0xFFFF9933); // Saffron
  static const Color primaryDark = Color(0xFFE65100); // Deeper saffron
  static const Color secondary = Color(0xFF2E7D32); // Deep organic green
  static const Color accent = Color(0xFFFBC02D); // Turmeric yellow

  // Feature colors
  static const Color screening = Color(0xFFE8930A); // Saffron
  static const Color cycleTracker = Color(0xFFE91E63); // Pink
  static const Color healthNotebook = Color(0xFF1A6B3A); // Green
  static const Color teleconsult = Color(0xFF2196F3); // Blue
  static const Color reminders = Color(0xFF9C27B0); // Purple
  static const Color nutrition = Color(0xFFFF9800); // Orange
  static const Color vhnMode = Color(0xFF607D8B); // Blue Grey

  // Backgrounds & Surfaces (No harsh whites)
  static const Color background = Color(0xFFFFF9F0); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);

  // Risk & Status Colors
  static const Color riskGreen = Color(0xFF2E7D32);
  static const Color riskYellow = Color(0xFFC97B00);
  static const Color riskRed = Color(0xFFC0392B);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5A5A5A);
}
