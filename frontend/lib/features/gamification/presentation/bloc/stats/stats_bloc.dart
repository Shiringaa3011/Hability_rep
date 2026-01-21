import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_stats.dart';
import '../../../domain/usecases/get_habits_stats.dart';
import '../../../domain/usecases/get_user_stats.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required this.getUserStats,
    required this.getHabitsStats,
  }) : super(const StatsInitial()) {
    on<LoadStats>(_onLoadStats);
    on<RefreshStats>(_onRefreshStats);
    on<ChangePeriod>(_onChangePeriod);
  }

  final GetUserStats getUserStats;
  final GetHabitsStats getHabitsStats;

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());

    await _fetchStats(event.userId, event.period, emit);
  }

  Future<void> _onRefreshStats(RefreshStats event, Emitter<StatsState> emit) async {
    await _fetchStats(event.userId, event.period, emit);
  }

  Future<void> _onChangePeriod(ChangePeriod event, Emitter<StatsState> emit) async {
    emit(const StatsLoading());
    await _fetchStats(event.userId, event.period, emit);
  }

  Future<void> _fetchStats(
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
      final errorMessage = statsResult.fold(
        (failure) => failure.message,
        (_) => habitsStatsResult.fold(
          (failure) => failure.message,
          (_) => 'Unknown error',
        ),
      );
      emit(StatsError(errorMessage));
      return;
    }

    final stats = statsResult.getOrElse(() => throw Exception());
    final habitsStats = habitsStatsResult.getOrElse(() => throw Exception());

    emit(StatsLoaded(stats: stats, habitsStats: habitsStats));
  }
}
