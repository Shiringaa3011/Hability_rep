import 'package:flutter/material.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    required this.streak,
    this.size = 24.0,
    super.key,
  });

  final int streak;

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = streak > 0;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.8, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: isActive ? Colors.orange : Colors.grey,
                size: size,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.orange : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
