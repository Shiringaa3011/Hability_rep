import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.trend,
    this.color,
    super.key,
  });

  final String title;

  final String value;

  final IconData icon;

  final String? subtitle;

  final double? trend;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: cardColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                if (trend != null) _buildTrendIndicator(theme),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(ThemeData theme) {
    if (trend == null || trend == 0) return const SizedBox.shrink();

    final isPositive = trend! > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: isPositive ? Colors.green : Colors.red,
        ),
        Text(
          '${trend!.abs()}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
