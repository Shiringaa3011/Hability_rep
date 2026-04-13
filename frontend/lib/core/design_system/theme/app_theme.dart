import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColorScheme c, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.primaryForeground,
      secondary: c.secondary,
      onSecondary: c.secondaryForeground,
      tertiary: c.accent,
      onTertiary: c.accentForeground,
      error: c.destructive,
      onError: c.destructiveForeground,
      surface: c.card,
      onSurface: c.cardForeground,
      surfaceContainerHighest: c.muted,
      onSurfaceVariant: c.mutedForeground,
      outline: c.border,
      outlineVariant: c.border,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      textTheme: _textTheme(c.foreground, c.mutedForeground),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: c.foreground),
      ),
      iconTheme: IconThemeData(color: c.foreground),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.input,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: c.ring, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.mutedForeground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.primaryForeground,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: AppTextStyles.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          side: BorderSide(color: c.border),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTextStyles.button,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.primaryForeground,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.secondary,
        selectedColor: c.primary,
        labelStyle: AppTextStyles.caption.copyWith(color: c.secondaryForeground),
        side: BorderSide(color: c.border),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillRadius),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.border,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(c.primaryForeground),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.primary : c.border,
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: c.card,
        iconColor: c.mutedForeground,
        textColor: c.foreground,
        titleTextStyle: AppTextStyles.titleSmall.copyWith(color: c.foreground),
        subtitleTextStyle: AppTextStyles.caption.copyWith(color: c.mutedForeground),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.card,
        indicatorColor: c.secondary,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.caption.copyWith(color: c.foreground),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? c.primary : c.mutedForeground,
            size: 24,
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color fg, Color muted) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: fg),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: fg),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: fg),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: fg),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: fg),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: fg),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: fg),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: muted),
      labelLarge: AppTextStyles.button.copyWith(color: fg),
      labelMedium: AppTextStyles.caption.copyWith(color: muted),
      labelSmall: AppTextStyles.overline.copyWith(color: muted),
    );
  }
}
