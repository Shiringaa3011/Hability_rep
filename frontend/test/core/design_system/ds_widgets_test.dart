import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/design_system/design_system.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  group('DSStreakBadge', () {
    testWidgets('hides when days <= 0', (tester) async {
      await tester.pumpWidget(_wrap(const DSStreakBadge(days: 0)));

      expect(find.byIcon(Icons.local_fire_department), findsNothing);
    });

    testWidgets('renders flame and pluralized days for 1', (tester) async {
      await tester.pumpWidget(_wrap(const DSStreakBadge(days: 1)));

      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.text('1 день'), findsOneWidget);
    });

    testWidgets('renders pluralized days for 2 (дня)', (tester) async {
      await tester.pumpWidget(_wrap(const DSStreakBadge(days: 3)));

      expect(find.text('3 дня'), findsOneWidget);
    });

    testWidgets('renders pluralized days for 5+ (дней)', (tester) async {
      await tester.pumpWidget(_wrap(const DSStreakBadge(days: 12)));

      expect(find.text('12 дней'), findsOneWidget);
    });
  });

  group('DSCheckCircle', () {
    testWidgets('shows check icon when checked', (tester) async {
      await tester.pumpWidget(
        _wrap(DSCheckCircle(checked: true, onTap: () {})),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('hides check icon when unchecked', (tester) async {
      await tester.pumpWidget(
        _wrap(DSCheckCircle(checked: false, onTap: () {})),
      );

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('invokes onTap when tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(DSCheckCircle(checked: false, onTap: () => taps++)),
      );

      await tester.tap(find.byType(DSCheckCircle));

      expect(taps, 1);
    });
  });

  group('DSProgressBar', () {
    testWidgets('clamps value to [0, 1]', (tester) async {
      await tester.pumpWidget(_wrap(const DSProgressBar(value: 1.5)));

      final bar = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );

      expect(bar.widthFactor, 1.0);
    });

    testWidgets('clamps negative value to 0', (tester) async {
      await tester.pumpWidget(_wrap(const DSProgressBar(value: -0.3)));

      final bar = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );

      expect(bar.widthFactor, 0.0);
    });
  });
}
