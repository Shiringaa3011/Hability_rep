import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DSAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DSAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final bool showBack;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 60 : 80);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveLeading = leading ??
        (showBack
            ? IconButton(
                icon: Icon(Icons.chevron_left, color: colors.foreground),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (effectiveLeading != null) ...[
              effectiveLeading,
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyles.titleLarge.copyWith(color: colors.foreground)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
