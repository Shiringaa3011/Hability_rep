import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/design_system/design_system.dart';
import 'package:habitly/features/gamification/domain/entities/timeline_point.dart';
import 'package:habitly/features/gamification/domain/entities/user_stats.dart';
import 'package:habitly/features/gamification/presentation/widgets/charts/habit_timeline_bar_chart.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru');
  });

  Widget _wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  final tWeekData = [
    TimelinePoint(date: DateTime(2026, 5, 10), points: 20),
    TimelinePoint(date: DateTime(2026, 5, 11), points: 30),
    TimelinePoint(date: DateTime(2026, 5, 12), points: 10),
  ];

  group('HabitTimelineBarChart — empty state', () {
    testWidgets('shows empty-state text when data is empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HabitTimelineBarChart(data: [], period: StatsPeriod.week),
        ),
      );

      expect(find.text('Нет данных для графика'), findsOneWidget);
    });

    testWidgets('empty-state container has fixed height of 180', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HabitTimelineBarChart(data: [], period: StatsPeriod.week),
        ),
      );

      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.height, 180);
    });

    testWidgets('does not render BarChart when data is empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HabitTimelineBarChart(data: [], period: StatsPeriod.week),
        ),
      );

      expect(find.byType(BarChart), findsNothing);
    });
  });

  group('HabitTimelineBarChart — normal render', () {
    testWidgets('renders BarChart when data is non-empty (week)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HabitTimelineBarChart(data: tWeekData, period: StatsPeriod.week),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('does not show empty-state text when data is non-empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HabitTimelineBarChart(data: tWeekData, period: StatsPeriod.week),
        ),
      );

      expect(find.text('Нет данных для графика'), findsNothing);
    });

    testWidgets('root SizedBox has height 180 when data is non-empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HabitTimelineBarChart(data: tWeekData, period: StatsPeriod.week),
        ),
      );

      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(boxes.any((b) => b.height == 180), isTrue);
    });

    testWidgets('renders BarChart for month period', (tester) async {
      final monthData = [
        TimelinePoint(date: DateTime(2026, 4, 11), points: 50),
        TimelinePoint(date: DateTime(2026, 4, 18), points: 70),
        TimelinePoint(date: DateTime(2026, 4, 25), points: 40),
        TimelinePoint(date: DateTime(2026, 5, 2), points: 60),
        TimelinePoint(date: DateTime(2026, 5, 9), points: 30),
      ];

      await tester.pumpWidget(
        _wrap(
          HabitTimelineBarChart(data: monthData, period: StatsPeriod.month),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
    });
  });

  group('HabitTimelineBarChart — edge cases', () {
    testWidgets('renders without crash when all points are zero', (tester) async {
      final allZero = [
        TimelinePoint(date: DateTime(2026, 5, 10), points: 0),
        TimelinePoint(date: DateTime(2026, 5, 11), points: 0),
      ];

      await tester.pumpWidget(
        _wrap(
          HabitTimelineBarChart(data: allZero, period: StatsPeriod.week),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Нет данных для графика'), findsNothing);
    });

    testWidgets('renders without crash for single-element list', (tester) async {
      final single = [
        TimelinePoint(date: DateTime(2026, 5, 16), points: 15),
      ];

      await tester.pumpWidget(
        _wrap(
          HabitTimelineBarChart(data: single, period: StatsPeriod.week),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders without crash for very large point values', (tester) async {
      final largeValues = [
        TimelinePoint(date: DateTime(2026, 5, 10), points: 10000),
        TimelinePoint(date: DateTime(2026, 5, 11), points: 9999),
      ];

      await tester.pumpWidget(
        _wrap(
          HabitTimelineBarChart(data: largeValues, period: StatsPeriod.week),
        ),
      );

      expect(find.byType(BarChart), findsOneWidget);
    });
  });
}
