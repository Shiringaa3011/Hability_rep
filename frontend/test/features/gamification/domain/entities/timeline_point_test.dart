import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/gamification/domain/entities/timeline_point.dart';

void main() {
  group('TimelinePoint', () {
    final tDate = DateTime(2026, 5, 10);

    test('should be a subclass of Equatable', () {
      final point = TimelinePoint(date: tDate, points: 42);

      expect(point, isA<Equatable>());
    });

    test('should hold the date and points values provided', () {
      final point = TimelinePoint(date: tDate, points: 42);

      expect(point.date, tDate);
      expect(point.points, 42);
    });

    test('should support value equality when date and points are identical', () {
      final point1 = TimelinePoint(date: tDate, points: 42);
      final point2 = TimelinePoint(date: tDate, points: 42);

      expect(point1, point2);
    });

    test('should not be equal when points differ', () {
      final point1 = TimelinePoint(date: tDate, points: 42);
      final point2 = TimelinePoint(date: tDate, points: 0);

      expect(point1, isNot(point2));
    });

    test('should not be equal when dates differ', () {
      final point1 = TimelinePoint(date: tDate, points: 42);
      final point2 = TimelinePoint(date: DateTime(2026, 5, 11), points: 42);

      expect(point1, isNot(point2));
    });

    test('should accept zero as a valid points value', () {
      final point = TimelinePoint(date: tDate, points: 0);

      expect(point.points, 0);
    });

    test('toString contains date and points', () {
      final point = TimelinePoint(date: tDate, points: 42);

      expect(point.toString(), contains('42'));
      expect(point.toString(), contains('TimelinePoint'));
    });
  });
}
