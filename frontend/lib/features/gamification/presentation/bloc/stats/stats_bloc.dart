import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/habit_stats.dart';
import '../../../domain/entities/timeline_point.dart';
import '../../../domain/entities/user_stats.dart';
import '../../../domain/usecases/complete_habit.dart';
import '../../../domain/usecases/get_habits_stats.dart';
import '../../../domain/usecases/get_user_stats.dart';
import '../../../domain/usecases/get_user_timeline.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required this.getUserStats,
    required this.getHabitsStats,
    required this.completeHabit,
    required this.getUserTimeline,
  }) : super(const StatsInitial()) {
    on<LoadStats>(_onLoadStats);
    on<RefreshStats>(_onRefreshStats);
    on<ChangePeriod>(_onChangePeriod);
    on<CompleteHabitEvent>(_onCompleteHabit);
  }

  final GetUserStats getUserStats;
  final GetHabitsStats getHabitsStats;
  final CompleteHabit completeHabit;
  final GetUserTimeline getUserTimeline;

  StatsPeriod currentPeriod = StatsPeriod.week;

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());

    await _fetchStats(event.userId, event.period, emit);
  }

  Future<void> _onRefreshStats(
      RefreshStats event, Emitter<StatsState> emit) async {
    await _fetchStats(event.userId, event.period, emit);
  }

  Future<void> _onChangePeriod(
      ChangePeriod event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());
    await _fetchStats(event.userId, event.period, emit);
  }

  Future<void> _onCompleteHabit(
    CompleteHabitEvent event,
    Emitter<StatsState> emit,
  ) async {
    final result = await completeHabit(
      CompleteHabitParams(habitId: event.habitId, userId: event.userId),
    );

    result.fold(
      (failure) => emit(HabitCompletionError(failure.message)),
      (newAchievements) =>
          emit(HabitCompleted(newAchievements: newAchievements)),
    );
  }

  Future<void> _fetchStats(
    String userId,
    StatsPeriod period,
    Emitter<StatsState> emit,
  ) async {
    currentPeriod = period;

    if (period == StatsPeriod.day) {
      await _fetchStatsForDay(userId, period, emit);
      return;
    }

    await _fetchStatsWithTimeline(userId, period, emit);
  }

  Future<void> _fetchStatsForDay(
    String userId,
    StatsPeriod period,
    Emitter<StatsState> emit,
  ) async {
    final statsResult = await getUserStats(
      GetUserStatsParams(userId: userId, period: period),
    );
    final habitsStatsResult = await getHabitsStats(
      GetHabitsStatsParams(userId: userId, period: period),
    );

    if (statsResult.isLeft() || habitsStatsResult.isLeft()) {
      emit(StatsError(_extractErrorMessage(statsResult, habitsStatsResult)));
      return;
    }

    emit(StatsLoaded(
      stats: statsResult.getOrElse(() => throw Exception()),
      habitsStats: habitsStatsResult.getOrElse(() => throw Exception()),
    ));
  }

  Future<void> _fetchStatsWithTimeline(
    String userId,
    StatsPeriod period,
    Emitter<StatsState> emit,
  ) async {
    final results = await Future.wait([
      getUserStats(GetUserStatsParams(userId: userId, period: period)),
      getHabitsStats(GetHabitsStatsParams(userId: userId, period: period)),
      getUserTimeline(GetUserTimelineParams(userId: userId, period: period)),
    ]);

    final statsResult = results[0] as Either<Failure, UserStats>;
    final habitsStatsResult = results[1] as Either<Failure, List<HabitStats>>;
    final timelineResult = results[2] as Either<Failure, List<TimelinePoint>>;

    if (statsResult.isLeft() || habitsStatsResult.isLeft()) {
      emit(StatsError(_extractErrorMessage(statsResult, habitsStatsResult)));
      return;
    }

    emit(StatsLoaded(
      stats: statsResult.getOrElse(() => throw Exception()),
      habitsStats: habitsStatsResult.getOrElse(() => throw Exception()),
      timeline: _resolveTimeline(timelineResult),
    ));
  }

  String _extractErrorMessage(
    Either<Failure, UserStats> statsResult,
    Either<Failure, List<HabitStats>> habitsStatsResult,
  ) =>
      statsResult.fold(
        (failure) => failure.message,
        (_) => habitsStatsResult.fold(
          (failure) => failure.message,
          (_) => 'Unknown error',
        ),
      );

  List<TimelinePoint> _resolveTimeline(
    Either<Failure, List<TimelinePoint>> result,
  ) =>
      result.getOrElse(() => const []);
}
