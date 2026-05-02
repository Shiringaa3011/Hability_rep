import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/error/exceptions.dart';
import 'package:habitly/core/error/failures.dart';
import 'package:habitly/features/gamification/data/datasources/gamification_local_datasource.dart';
import 'package:habitly/features/gamification/data/datasources/gamification_remote_datasource.dart';
import 'package:habitly/features/gamification/data/models/timeline_point_model.dart';
import 'package:habitly/features/gamification/data/repositories/gamification_repository_impl.dart';
import 'package:habitly/features/gamification/domain/entities/timeline_point.dart';
import 'package:habitly/features/gamification/domain/entities/user_stats.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'gamification_repository_impl_timeline_test.mocks.dart';

@GenerateMocks([GamificationRemoteDataSource, GamificationLocalDataSource])
void main() {
  late GamificationRepositoryImpl repository;
  late MockGamificationRemoteDataSource mockRemoteDataSource;
  late MockGamificationLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockGamificationRemoteDataSource();
    mockLocalDataSource = MockGamificationLocalDataSource();
    repository = GamificationRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tUserId = 'user-123';
  final tModels = [
    const TimelinePointModel(date: '2026-05-04', points: 10),
    const TimelinePointModel(date: '2026-05-05', points: 25),
  ];
  final tEntities = [
    TimelinePoint(date: DateTime(2026, 5, 4), points: 10),
    TimelinePoint(date: DateTime(2026, 5, 5), points: 25),
  ];

  group('getUserTimeline', () {
    test('should return Right with list of TimelinePoint on success', () async {
      when(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.week))
          .thenAnswer((_) async => tModels);

      final result = await repository.getUserTimeline(tUserId, StatsPeriod.week);

      result.fold(
        (_) => fail('Expected Right but got Left'),
        (points) {
          expect(points.length, tEntities.length);
          expect(points[0].date, tEntities[0].date);
          expect(points[0].points, tEntities[0].points);
          expect(points[1].date, tEntities[1].date);
          expect(points[1].points, tEntities[1].points);
        },
      );
      verify(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.week));
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return Right with empty list when datasource returns empty list', () async {
      when(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.week))
          .thenAnswer((_) async => []);

      final result = await repository.getUserTimeline(tUserId, StatsPeriod.week);

      result.fold(
        (_) => fail('Expected Right but got Left'),
        (points) => expect(points, isEmpty),
      );
    });

    test('should return Right for month period', () async {
      when(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.month))
          .thenAnswer((_) async => tModels);

      final result = await repository.getUserTimeline(tUserId, StatsPeriod.month);

      expect(result.isRight(), isTrue);
      verify(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.month));
    });

    test('should return Left(ServerFailure) when datasource throws ServerException', () async {
      when(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.week))
          .thenThrow(const ServerException('Failed to get user timeline: 422'));

      final result = await repository.getUserTimeline(tUserId, StatsPeriod.week);

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to get user timeline: 422');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(NetworkFailure) when datasource throws NetworkException', () async {
      when(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.week))
          .thenThrow(const NetworkException('Connection timeout'));

      final result = await repository.getUserTimeline(tUserId, StatsPeriod.week);

      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'Connection timeout');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(ServerFailure) on unexpected exception', () async {
      when(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.week))
          .thenThrow(Exception('Something went wrong'));

      final result = await repository.getUserTimeline(tUserId, StatsPeriod.week);

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Unexpected error'));
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should not interact with local datasource', () async {
      when(mockRemoteDataSource.getUserTimeline(tUserId, StatsPeriod.week))
          .thenAnswer((_) async => []);

      await repository.getUserTimeline(tUserId, StatsPeriod.week);

      verifyZeroInteractions(mockLocalDataSource);
    });
  });
}
