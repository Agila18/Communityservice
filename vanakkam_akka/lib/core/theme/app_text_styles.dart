import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography settings customized for optimal Tamil legibility
class AppTextStyles {
  AppTextStyles._();

  // Body: high-legibility Tamil (Noto); headings: warm display (Arima Madurai).
  static TextStyle get _bodyBase => GoogleFonts.notoSansTamil(
        color: AppColors.textPrimary,
      );

  /// Arima family (closest bundled to “Arima Madurai”); falls back via Google Fonts.
  static TextStyle get _displayBase => GoogleFonts.arima(
        color: AppColors.textPrimary,
      );

  // Headings
  static TextStyle get headingLarge => _displayBase.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headingMedium => _displayBase.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  // Body text - High line height (1.7) is critical for Tamil script
  // to prevent overlapping of top and bottom modifiers
  static TextStyle get bodyLarge => _bodyBase.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.7, 
      );

  static TextStyle get bodySmall => _bodyBase.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  // Specific UI elements
  static TextStyle get voiceHint => _bodyBase.copyWith(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: AppColors.textSecondary,
      );

  static TextStyle get riskLabel => _bodyBase.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );
}
