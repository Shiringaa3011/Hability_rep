import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DSSectionHeader extends StatelessWidget {
  const DSSectionHeader({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(color: colors.mutedForeground),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
