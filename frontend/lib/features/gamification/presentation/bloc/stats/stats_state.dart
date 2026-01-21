import 'package:equatable/equatable.dart';

import '../../../domain/entities/habit_stats.dart';
import '../../../domain/entities/user_stats.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  const StatsLoaded({
    required this.stats,
    required this.habitsStats,
  });

  final UserStats stats;
  final List<HabitStats> habitsStats;

  @override
  List<Object?> get props => [stats, habitsStats];
}

class StatsError extends StatsState {
  const StatsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
