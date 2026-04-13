import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class DSCheckCircle extends StatelessWidget {
  const DSCheckCircle({
    super.key,
    required this.checked,
    required this.onTap,
    this.size = 32,
  });

  final bool checked;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: checked ? colors.primary : Colors.transparent,
          border: Border.all(
            color: checked ? colors.primary : colors.border,
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child: checked
            ? Icon(Icons.check, size: size * 0.55, color: colors.primaryForeground)
            : null,
      ),
    );
  }
}
