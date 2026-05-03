import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get displayLarge =>
      _base(size: 32, weight: FontWeight.w700, height: 1.15);

  static TextStyle get displayMedium =>
      _base(size: 26, weight: FontWeight.w700, height: 1.2);

  static TextStyle get titleLarge =>
      _base(size: 20, weight: FontWeight.w700, height: 1.25);

  static TextStyle get titleMedium =>
      _base(size: 16, weight: FontWeight.w600, height: 1.35);

  static TextStyle get titleSmall =>
      _base(size: 14, weight: FontWeight.w600, height: 1.4);

  static TextStyle get bodyLarge =>
      _base(size: 15, weight: FontWeight.w500, height: 1.45);

  static TextStyle get bodyMedium =>
      _base(size: 14, weight: FontWeight.w500, height: 1.45);

  static TextStyle get bodySmall =>
      _base(size: 13, weight: FontWeight.w500, height: 1.4);

  static TextStyle get caption =>
      _base(size: 12, weight: FontWeight.w500, height: 1.35);

  static TextStyle get overline => _base(
        size: 11,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 1.4,
      );

  static TextStyle get button =>
      _base(size: 14, weight: FontWeight.w600, height: 1.2);

  static TextStyle get number =>
      _base(size: 14, weight: FontWeight.w700, height: 1.2);
}
