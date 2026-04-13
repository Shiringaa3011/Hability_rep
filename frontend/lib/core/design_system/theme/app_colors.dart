import 'package:flutter/material.dart';

class AppColorScheme {
  const AppColorScheme({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.streak,
    required this.streakForeground,
    required this.success,
    required this.successForeground,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color border;
  final Color input;
  final Color ring;
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;
  final Color streak;
  final Color streakForeground;
  final Color success;
  final Color successForeground;
}

class AppColors {
  const AppColors._();

  static const AppColorScheme light = AppColorScheme(
    background: Color(0xFFF5F8F3),
    foreground: Color(0xFF0C140F),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF0C140F),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF0C140F),
    primary: Color(0xFF418D50),
    primaryForeground: Color(0xFFFFFFFF),
    secondary: Color(0xFFDEF1E0),
    secondaryForeground: Color(0xFF174521),
    muted: Color(0xFFEDEFEC),
    mutedForeground: Color(0xFF606D64),
    accent: Color(0xFF2A6736),
    accentForeground: Color(0xFFFFFFFF),
    destructive: Color(0xFFCF4040),
    destructiveForeground: Color(0xFFFFFFFF),
    border: Color(0xFFDDE3DC),
    input: Color(0xFFEDEFEC),
    ring: Color(0xFF418D50),
    chart1: Color(0xFF418D50),
    chart2: Color(0xFF72B07B),
    chart3: Color(0xFFA1D3A7),
    chart4: Color(0xFF2B6241),
    chart5: Color(0xFF55A181),
    streak: Color(0xFFE09036),
    streakForeground: Color(0xFFFFFFFF),
    success: Color(0xFF418D50),
    successForeground: Color(0xFFFFFFFF),
  );

  static const AppColorScheme dark = AppColorScheme(
    background: Color(0xFF050806),
    foreground: Color(0xFFE7EDE7),
    card: Color(0xFF101511),
    cardForeground: Color(0xFFE7EDE7),
    popover: Color(0xFF101511),
    popoverForeground: Color(0xFFE7EDE7),
    primary: Color(0xFF57A364),
    primaryForeground: Color(0xFF050806),
    secondary: Color(0xFF172018),
    secondaryForeground: Color(0xFFC5D2C7),
    muted: Color(0xFF191E1B),
    mutedForeground: Color(0xFF828883),
    accent: Color(0xFF45814F),
    accentForeground: Color(0xFF050806),
    destructive: Color(0xFFBA2B2E),
    destructiveForeground: Color(0xFFE7EDE7),
    border: Color(0xFF1E2621),
    input: Color(0xFF191E1B),
    ring: Color(0xFF57A364),
    chart1: Color(0xFF57A364),
    chart2: Color(0xFF7EBC87),
    chart3: Color(0xFFA9D4AE),
    chart4: Color(0xFF3A714F),
    chart5: Color(0xFF5EAA8A),
    streak: Color(0xFFED9D44),
    streakForeground: Color(0xFF050806),
    success: Color(0xFF57A364),
    successForeground: Color(0xFF050806),
  );
}

extension AppColorsContext on BuildContext {
  AppColorScheme get appColors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  }
}
