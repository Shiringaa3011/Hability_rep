import 'package:flutter/material.dart';

class LevelProgressBar extends StatelessWidget {
  const LevelProgressBar({
    required this.currentLevel,
    required this.progress,
    required this.currentPoints,
    required this.pointsToNext,
    super.key,
  });

  final int currentLevel;

  final double progress;

  final int currentPoints;

  final int pointsToNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Уровень $currentLevel',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Уровень ${currentLevel + 1}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            tween: Tween(begin: 0.0, end: progress / 100),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 20,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.primaryColor,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Еще $pointsToNext баллов',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
