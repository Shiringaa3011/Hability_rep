import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DSStreakBadge extends StatelessWidget {
  const DSStreakBadge({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    if (days <= 0) return const SizedBox.shrink();

    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, size: 14, color: colors.streak),
        const SizedBox(width: 4),
        Text(
          '$days ${_pluralizeDays(days)}',
          style: AppTextStyles.caption.copyWith(
            color: colors.streak,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  static String _pluralizeDays(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'дней';
    if (mod10 == 1) return 'день';
    if (mod10 >= 2 && mod10 <= 4) return 'дня';
    return 'дней';
  }
}
