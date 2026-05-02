import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/error/failures.dart';
import 'package:habitly/features/gamification/domain/entities/habit_stats.dart';
import 'package:habitly/features/gamification/domain/entities/timeline_point.dart';
import 'package:habitly/features/gamification/domain/entities/user_stats.dart';
import 'package:habitly/features/gamification/domain/usecases/complete_habit.dart';
import 'package:habitly/features/gamification/domain/usecases/get_habits_stats.dart';
import 'package:habitly/features/gamification/domain/usecases/get_user_stats.dart';
import 'package:habitly/features/gamification/domain/usecases/get_user_timeline.dart';
import 'package:habitly/features/gamification/presentation/bloc/stats/stats_bloc.dart';
import 'package:habitly/features/gamification/presentation/bloc/stats/stats_event.dart';
import 'package:habitly/features/gamification/presentation/bloc/stats/stats_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'stats_bloc_test.mocks.dart';

@GenerateMocks([GetUserStats, GetHabitsStats, GetUserTimeline, CompleteHabit])
void main() {
  late StatsBloc bloc;
  late MockGetUserStats mockGetUserStats;
  late MockGetHabitsStats mockGetHabitsStats;
  late MockGetUserTimeline mockGetUserTimeline;
  late MockCompleteHabit mockCompleteHabit;

  late UserStats tUserStats;
  late UserStats tUserStatsDay;
  late List<HabitStats> tHabitsStats;
  late List<TimelinePoint> tTimeline;

  const tUserId = 'user-abc';

  setUp(() {
    mockGetUserStats = MockGetUserStats();
    mockGetHabitsStats = MockGetHabitsStats();
    mockGetUserTimeline = MockGetUserTimeline();
    mockCompleteHabit = MockCompleteHabit();

    bloc = StatsBloc(
      getUserStats: mockGetUserStats,
      getHabitsStats: mockGetHabitsStats,
      completeHabit: mockCompleteHabit,
      getUserTimeline: mockGetUserTimeline,
    );

    final tUpdatedAt = DateTime(2026, 5, 16);

    tUserStats = UserStats(
      userId: tUserId,
      period: StatsPeriod.week,
      totalCompletions: 10,
      completionRate: 0.8,
      currentStreak: 3,
      maxStreak: 7,
      totalPointsEarned: 150,
      missedCount: 2,
      updatedAt: tUpdatedAt,
    );

    tUserStatsDay = UserStats(
      userId: tUserId,
      period: StatsPeriod.day,
      totalCompletions: 2,
      completionRate: 1.0,
      currentStreak: 1,
      maxStreak: 3,
      totalPointsEarned: 30,
      missedCount: 0,
      updatedAt: tUpdatedAt,
    );

    tHabitsStats = const [
      HabitStats(
        habitId: 'h1',
        habitName: 'Run',
        totalCompletions: 5,
        currentStreak: 3,
        maxStreak: 7,
        totalPointsEarned: 75,
        completionRate: 0.71,
      ),
    ];

    tTimeline = [
      TimelinePoint(date: DateTime(2026, 5, 10), points: 20),
      TimelinePoint(date: DateTime(2026, 5, 11), points: 30),
    ];
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is StatsInitial', () {
    expect(bloc.state, const StatsInitial());
  });

  group('LoadStats — week period', () {
    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsLoaded] with timeline when all calls succeed',
      build: () {
        when(mockGetUserStats(any)).thenAnswer((_) async => Right(tUserStats));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        when(mockGetUserTimeline(any))
            .thenAnswer((_) async => Right(tTimeline));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.week)),
      expect: () => [
        const StatsLoading(),
        StatsLoaded(
          stats: tUserStats,
          habitsStats: tHabitsStats,
          timeline: tTimeline,
        ),
      ],
      verify: (_) {
        verify(mockGetUserStats(any));
        verify(mockGetHabitsStats(any));
        verify(mockGetUserTimeline(any));
      },
    );

    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsError] when getUserStats fails',
      build: () {
        when(mockGetUserStats(any)).thenAnswer(
            (_) async => const Left(ServerFailure('stats error')));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        when(mockGetUserTimeline(any))
            .thenAnswer((_) async => Right(tTimeline));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.week)),
      expect: () => [
        const StatsLoading(),
        const StatsError('stats error'),
      ],
    );

    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsError] when getHabitsStats fails',
      build: () {
        when(mockGetUserStats(any)).thenAnswer((_) async => Right(tUserStats));
        when(mockGetHabitsStats(any)).thenAnswer(
            (_) async => const Left(ServerFailure('habits error')));
        when(mockGetUserTimeline(any))
            .thenAnswer((_) async => Right(tTimeline));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.week)),
      expect: () => [
        const StatsLoading(),
        const StatsError('habits error'),
      ],
    );

    blocTest<StatsBloc, StatsState>(
      'emits StatsLoaded with empty timeline when getUserTimeline fails — graceful degrade',
      build: () {
        when(mockGetUserStats(any)).thenAnswer((_) async => Right(tUserStats));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        when(mockGetUserTimeline(any)).thenAnswer(
            (_) async => const Left(NetworkFailure('timeout')));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.week)),
      expect: () => [
        const StatsLoading(),
        StatsLoaded(
          stats: tUserStats,
          habitsStats: tHabitsStats,
        ),
      ],
      verify: (_) {
        verify(mockGetUserStats(any));
        verify(mockGetHabitsStats(any));
        verify(mockGetUserTimeline(any));
      },
    );

    blocTest<StatsBloc, StatsState>(
      'emits StatsLoaded with empty timeline when getUserTimeline returns Right([])',
      build: () {
        when(mockGetUserStats(any)).thenAnswer((_) async => Right(tUserStats));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        when(mockGetUserTimeline(any)).thenAnswer(
            (_) async => const Right<Failure, List<TimelinePoint>>([]));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.week)),
      expect: () => [
        const StatsLoading(),
        StatsLoaded(
          stats: tUserStats,
          habitsStats: tHabitsStats,
        ),
      ],
    );
  });

  group('LoadStats — month period', () {
    blocTest<StatsBloc, StatsState>(
      'emits StatsLoaded with timeline for month period',
      build: () {
        when(mockGetUserStats(any)).thenAnswer((_) async => Right(tUserStats));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        when(mockGetUserTimeline(any))
            .thenAnswer((_) async => Right(tTimeline));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.month)),
      expect: () => [
        const StatsLoading(),
        StatsLoaded(
          stats: tUserStats,
          habitsStats: tHabitsStats,
          timeline: tTimeline,
        ),
      ],
      verify: (_) {
        verify(mockGetUserTimeline(any));
      },
    );
  });

  group('LoadStats — day period', () {
    blocTest<StatsBloc, StatsState>(
      'emits StatsLoaded with empty timeline and does NOT call getUserTimeline',
      build: () {
        when(mockGetUserStats(any))
            .thenAnswer((_) async => Right(tUserStatsDay));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.day)),
      expect: () => [
        const StatsLoading(),
        StatsLoaded(
          stats: tUserStatsDay,
          habitsStats: tHabitsStats,
        ),
      ],
      verify: (_) {
        verifyNever(mockGetUserTimeline(any));
      },
    );

    blocTest<StatsBloc, StatsState>(
      'emits StatsError when getUserStats fails for day period — does NOT call getUserTimeline',
      build: () {
        when(mockGetUserStats(any)).thenAnswer(
            (_) async => const Left(ServerFailure('day stats error')));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        return bloc;
      },
      act: (b) =>
          b.add(const LoadStats(userId: tUserId, period: StatsPeriod.day)),
      expect: () => [
        const StatsLoading(),
        const StatsError('day stats error'),
      ],
      verify: (_) {
        verifyNever(mockGetUserTimeline(any));
      },
    );
  });

  group('ChangePeriod', () {
    blocTest<StatsBloc, StatsState>(
      'emits [StatsLoading, StatsLoaded] with timeline when switching to week',
      build: () {
        when(mockGetUserStats(any)).thenAnswer((_) async => Right(tUserStats));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        when(mockGetUserTimeline(any))
            .thenAnswer((_) async => Right(tTimeline));
        return bloc;
      },
      act: (b) =>
          b.add(const ChangePeriod(userId: tUserId, period: StatsPeriod.week)),
      expect: () => [
        const StatsLoading(),
        StatsLoaded(
          stats: tUserStats,
          habitsStats: tHabitsStats,
          timeline: tTimeline,
        ),
      ],
    );

    blocTest<StatsBloc, StatsState>(
      'does NOT call getUserTimeline when switching to day period',
      build: () {
        when(mockGetUserStats(any))
            .thenAnswer((_) async => Right(tUserStatsDay));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        return bloc;
      },
      act: (b) =>
          b.add(const ChangePeriod(userId: tUserId, period: StatsPeriod.day)),
      expect: () => [
        const StatsLoading(),
        StatsLoaded(
          stats: tUserStatsDay,
          habitsStats: tHabitsStats,
        ),
      ],
      verify: (_) {
        verifyNever(mockGetUserTimeline(any));
      },
    );
  });

  group('RefreshStats', () {
    blocTest<StatsBloc, StatsState>(
      'emits StatsLoaded with timeline (no StatsLoading) on refresh for week',
      build: () {
        when(mockGetUserStats(any)).thenAnswer((_) async => Right(tUserStats));
        when(mockGetHabitsStats(any))
            .thenAnswer((_) async => Right(tHabitsStats));
        when(mockGetUserTimeline(any))
            .thenAnswer((_) async => Right(tTimeline));
        return bloc;
      },
      act: (b) =>
          b.add(const RefreshStats(userId: tUserId, period: StatsPeriod.week)),
      expect: () => [
        StatsLoaded(
          stats: tUserStats,
          habitsStats: tHabitsStats,
          timeline: tTimeline,
        ),
      ],
    );
  });

  group('StatsLoaded — equality and defaults', () {
    test('two instances with identical fields are equal', () {
      final a = StatsLoaded(
        stats: tUserStats,
        habitsStats: tHabitsStats,
        timeline: tTimeline,
      );
      final b = StatsLoaded(
        stats: tUserStats,
        habitsStats: tHabitsStats,
        timeline: tTimeline,
      );

      expect(a, equals(b));
    });

    test('instances with different timelines are not equal', () {
      final withTimeline = StatsLoaded(
        stats: tUserStats,
        habitsStats: tHabitsStats,
        timeline: tTimeline,
      );
      final withoutTimeline = StatsLoaded(
        stats: tUserStats,
        habitsStats: tHabitsStats,
      );

      expect(withTimeline, isNot(equals(withoutTimeline)));
    });

    test('defaults timeline to empty list when omitted', () {
      final state = StatsLoaded(
        stats: tUserStats,
        habitsStats: tHabitsStats,
      );

      expect(state.timeline, isEmpty);
    });
  });
}
