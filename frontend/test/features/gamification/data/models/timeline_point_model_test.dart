import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/gamification/data/models/timeline_point_model.dart';
import 'package:habitly/features/gamification/domain/entities/timeline_point.dart';

void main() {
  group('TimelinePointModel', () {
    group('fromJson', () {
      test('should parse date and points from valid JSON', () {
        final json = {'date': '2026-05-10', 'points': 45};

        final model = TimelinePointModel.fromJson(json);

        expect(model.date, '2026-05-10');
        expect(model.points, 45);
      });

      test('should parse zero points from JSON', () {
        final json = {'date': '2026-05-10', 'points': 0};

        final model = TimelinePointModel.fromJson(json);

        expect(model.points, 0);
      });

      test('should parse large points value from JSON', () {
        final json = {'date': '2026-01-01', 'points': 99999};

        final model = TimelinePointModel.fromJson(json);

        expect(model.points, 99999);
      });

      test('should throw TypeError when points field is a double', () {
        final json = {'date': '2026-05-10', 'points': 123.0};

        expect(() => TimelinePointModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw TypeError when points field is a string', () {
        final json = {'date': '2026-05-10', 'points': '45'};

        expect(() => TimelinePointModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw TypeError when date field is not a string', () {
        final json = {'date': 20260510, 'points': 45};

        expect(() => TimelinePointModel.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('toEntity', () {
      test('should convert to TimelinePoint with parsed DateTime', () {
        const model = TimelinePointModel(date: '2026-05-10', points: 45);

        final entity = model.toEntity();

        expect(entity, isA<TimelinePoint>());
        expect(entity.date, DateTime(2026, 5, 10));
        expect(entity.points, 45);
      });

      test('should convert zero points correctly', () {
        const model = TimelinePointModel(date: '2026-05-10', points: 0);

        final entity = model.toEntity();

        expect(entity.points, 0);
      });

      test('should throw FormatException when date string is not a valid ISO date', () {
        const model = TimelinePointModel(date: 'not-a-date', points: 10);

        expect(() => model.toEntity(), throwsA(isA<FormatException>()));
      });

      test('should parse first day of month correctly', () {
        const model = TimelinePointModel(date: '2026-01-01', points: 10);

        final entity = model.toEntity();

        expect(entity.date, DateTime(2026, 1, 1));
      });
    });
  });
}
