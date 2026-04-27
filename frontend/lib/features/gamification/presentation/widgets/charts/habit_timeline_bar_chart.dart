import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/design_system/design_system.dart';
import '../../../domain/entities/timeline_point.dart';
import '../../../domain/entities/user_stats.dart';

class HabitTimelineBarChart extends StatelessWidget {
  const HabitTimelineBarChart({
    required this.data,
    required this.period,
    super.key,
  });

  final List<TimelinePoint> data;
  final StatsPeriod period;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (data.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'Нет данных для графика',
            style: AppTextStyles.bodyMedium
                .copyWith(color: colors.mutedForeground),
          ),
        ),
      );
    }

    final rawMax = data.map((p) => p.points).reduce(max).toDouble();
    final maxY = max(rawMax, 1.0);
    final interval = max(1.0, (maxY / 4).ceilToDouble());

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barGroups: _buildGroups(data, colors.chart1),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: colors.border, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: interval,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: AppTextStyles.caption
                      .copyWith(color: colors.mutedForeground),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, m) => Text(
                  _xLabel(v.toInt(), data, period),
                  style: AppTextStyles.caption
                      .copyWith(color: colors.mutedForeground),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: const BarTouchData(enabled: false),
        ),
      ),
    );
  }

  static List<BarChartGroupData> _buildGroups(
    List<TimelinePoint> data,
    Color barColor,
  ) {
    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: data[i].points.toDouble(),
            color: barColor,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  static String _xLabel(
      int index, List<TimelinePoint> data, StatsPeriod period) {
    final date = data[index].date;
    return DateFormat('d\nMMM', 'ru').format(date);
  }
}
