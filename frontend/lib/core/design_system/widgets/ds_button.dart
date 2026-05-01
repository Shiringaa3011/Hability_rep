import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

enum DSButtonVariant { primary, secondary, ghost, destructive }

enum DSButtonSize { small, medium, large }

class DSButton extends StatelessWidget {
  const DSButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.medium,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final IconData? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = _palette(colors);
    final dims = _dims();

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: dims.iconSize, color: palette.fg),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.button.copyWith(color: palette.fg, fontSize: dims.fontSize),
        ),
      ],
    );

    final button = Material(
      color: palette.bg,
      borderRadius: AppRadius.buttonRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.buttonRadius,
        child: Container(
          padding: dims.padding,
          decoration: BoxDecoration(
            borderRadius: AppRadius.buttonRadius,
            border: palette.border == null ? null : Border.all(color: palette.border!),
          ),
          child: content,
        ),
      ),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  _Palette _palette(AppColorScheme c) {
    switch (variant) {
      case DSButtonVariant.primary:
        return _Palette(bg: c.primary, fg: c.primaryForeground);
      case DSButtonVariant.secondary:
        return _Palette(bg: c.secondary, fg: c.secondaryForeground);
      case DSButtonVariant.ghost:
        return _Palette(bg: Colors.transparent, fg: c.foreground, border: c.border);
      case DSButtonVariant.destructive:
        return _Palette(bg: c.destructive, fg: c.destructiveForeground);
    }
  }

  _Dims _dims() {
    switch (size) {
      case DSButtonSize.small:
        return const _Dims(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          fontSize: 13,
          iconSize: 16,
        );
      case DSButtonSize.medium:
        return const _Dims(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          fontSize: 14,
          iconSize: 18,
        );
      case DSButtonSize.large:
        return const _Dims(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          fontSize: 15,
          iconSize: 20,
        );
    }
  }
}

class _Palette {
  const _Palette({required this.bg, required this.fg, this.border});
  final Color bg;
  final Color fg;
  final Color? border;
}

class _Dims {
  const _Dims({required this.padding, required this.fontSize, required this.iconSize});
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
}
