import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/gamification/domain/entities/user_level.dart';

void main() {
  group('UserLevel', () {
    test('should be a subclass of Equatable', () {
      const userLevel = UserLevel(
        userId: 'test-id',
        level: 5,
        totalPoints: 2500,
        pointsToNextLevel: 1100,
        progressPercent: 69.4,
      );

      expect(userLevel, isA<Equatable>());
    });

    test('should have correct properties', () {
      const userLevel = UserLevel(
        userId: 'test-id',
        level: 5,
        totalPoints: 2500,
        pointsToNextLevel: 1100,
        progressPercent: 69.4,
      );

      expect(userLevel.userId, 'test-id');
      expect(userLevel.level, 5);
      expect(userLevel.totalPoints, 2500);
      expect(userLevel.pointsToNextLevel, 1100);
      expect(userLevel.progressPercent, 69.4);
    });

    test('should support value equality', () {
      const userLevel1 = UserLevel(
        userId: 'test-id',
        level: 5,
        totalPoints: 2500,
        pointsToNextLevel: 1100,
        progressPercent: 69.4,
      );

      const userLevel2 = UserLevel(
        userId: 'test-id',
        level: 5,
        totalPoints: 2500,
        pointsToNextLevel: 1100,
        progressPercent: 69.4,
      );

      expect(userLevel1, userLevel2);
    });

    test('should not be equal when properties differ', () {
      const userLevel1 = UserLevel(
        userId: 'test-id',
        level: 5,
        totalPoints: 2500,
        pointsToNextLevel: 1100,
        progressPercent: 69.4,
      );

      const userLevel2 = UserLevel(
        userId: 'test-id',
        level: 6,
        totalPoints: 3600,
        pointsToNextLevel: 2500,
        progressPercent: 20.0,
      );

      expect(userLevel1, isNot(userLevel2));
    });
  });
}
