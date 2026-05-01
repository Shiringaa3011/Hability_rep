import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DSProgressBar extends StatelessWidget {
  const DSProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.trackColor,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Container(color: trackColor ?? colors.border),
            FractionallySizedBox(
              widthFactor: clamped,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                color: color ?? colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
