import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({
    required this.completed,
    required this.total,
    this.size = 150,
    super.key,
  });

  final int completed;

  final int total;

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (completed / total * 100) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: completed.toDouble(),
                  color: theme.primaryColor,
                  title: '',
                  radius: size / 4,
                ),
                PieChartSectionData(
                  value: (total - completed).toDouble(),
                  color: theme.colorScheme.surfaceVariant,
                  title: '',
                  radius: size / 4,
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: size / 3,
              startDegreeOffset: -90,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              Text(
                '$completed/$total',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
