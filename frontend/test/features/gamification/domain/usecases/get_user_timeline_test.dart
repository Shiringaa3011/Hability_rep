import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/error/failures.dart';
import 'package:habitly/features/gamification/domain/entities/timeline_point.dart';
import 'package:habitly/features/gamification/domain/entities/user_stats.dart';
import 'package:habitly/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:habitly/features/gamification/domain/usecases/get_user_timeline.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_timeline_test.mocks.dart';

@GenerateMocks([GamificationRepository])
void main() {
  late GetUserTimeline usecase;
  late MockGamificationRepository mockRepository;

  setUp(() {
    mockRepository = MockGamificationRepository();
    usecase = GetUserTimeline(mockRepository);
  });

  const tUserId = 'user-123';
  final tDate1 = DateTime(2026, 5, 9);
  final tDate2 = DateTime(2026, 5, 10);
  final tTimeline = [
    TimelinePoint(date: tDate1, points: 10),
    TimelinePoint(date: tDate2, points: 25),
  ];

  group('GetUserTimeline', () {
    test('should return timeline list from repository for week period', () async {
      when(mockRepository.getUserTimeline(tUserId, StatsPeriod.week))
          .thenAnswer((_) async => Right(tTimeline));

      final result = await usecase(
        const GetUserTimelineParams(userId: tUserId, period: StatsPeriod.week),
      );

      expect(result, Right(tTimeline));
      verify(mockRepository.getUserTimeline(tUserId, StatsPeriod.week));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return timeline list from repository for month period', () async {
      when(mockRepository.getUserTimeline(tUserId, StatsPeriod.month))
          .thenAnswer((_) async => Right(tTimeline));

      final result = await usecase(
        const GetUserTimelineParams(userId: tUserId, period: StatsPeriod.month),
      );

      expect(result, Right(tTimeline));
      verify(mockRepository.getUserTimeline(tUserId, StatsPeriod.month));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when repository returns empty timeline', () async {
      when(mockRepository.getUserTimeline(tUserId, StatsPeriod.week))
          .thenAnswer((_) async => const Right<Failure, List<TimelinePoint>>([]));

      final result = await usecase(
        const GetUserTimelineParams(userId: tUserId, period: StatsPeriod.week),
      );

      expect(result, const Right<Failure, List<TimelinePoint>>([]));
      verify(mockRepository.getUserTimeline(tUserId, StatsPeriod.week));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate Left(Failure) from repository without wrapping', () async {
      const tFailure = ServerFailure('Connection timed out');
      when(mockRepository.getUserTimeline(tUserId, StatsPeriod.week))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await usecase(
        const GetUserTimelineParams(userId: tUserId, period: StatsPeriod.week),
      );

      expect(result, const Left(tFailure));
      verify(mockRepository.getUserTimeline(tUserId, StatsPeriod.week));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass day period through to repository without interception', () async {
      when(mockRepository.getUserTimeline(tUserId, StatsPeriod.day))
          .thenAnswer((_) async => const Right<Failure, List<TimelinePoint>>([]));

      final result = await usecase(
        const GetUserTimelineParams(userId: tUserId, period: StatsPeriod.day),
      );

      expect(result, const Right<Failure, List<TimelinePoint>>([]));
      verify(mockRepository.getUserTimeline(tUserId, StatsPeriod.day));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass empty userId to repository without validation', () async {
      when(mockRepository.getUserTimeline('', StatsPeriod.week))
          .thenAnswer((_) async => const Right<Failure, List<TimelinePoint>>([]));

      final result = await usecase(
        const GetUserTimelineParams(userId: '', period: StatsPeriod.week),
      );

      expect(result, const Right<Failure, List<TimelinePoint>>([]));
      verify(mockRepository.getUserTimeline('', StatsPeriod.week));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
