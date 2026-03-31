import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography settings customized for optimal Tamil legibility
class AppTextStyles {
  AppTextStyles._();

  // Base font that supports Tamil comprehensively
  static TextStyle get _baseStyle => GoogleFonts.notoSansTamil(
        color: AppColors.textPrimary,
      );

  // Headings
  static TextStyle get headingLarge => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingMedium => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  // Body text - High line height (1.7) is critical for Tamil script
  // to prevent overlapping of top and bottom modifiers
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.7, 
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  // Specific UI elements
  static TextStyle get voiceHint => _baseStyle.copyWith(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: AppColors.textSecondary,
      );

  static TextStyle get riskLabel => _baseStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
}
