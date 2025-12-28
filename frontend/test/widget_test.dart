import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/gamification/presentation/widgets/stat_card.dart';
import 'package:habitly/features/gamification/presentation/widgets/streak_indicator.dart';

void main() {
  group('StatCard Widget', () {
    testWidgets('should display title and value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Test Stat',
              value: '42',
              icon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.text('Test Stat'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should display subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Test',
              value: '100',
              icon: Icons.check,
              subtitle: 'Test subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Test subtitle'), findsOneWidget);
    });
  });

  group('StreakIndicator Widget', () {
    testWidgets('should display streak number', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakIndicator(streak: 7),
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('should display zero streak', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakIndicator(streak: 0),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });
  });
}
