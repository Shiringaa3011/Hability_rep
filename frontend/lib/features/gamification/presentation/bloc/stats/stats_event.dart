import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_stats.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStats extends StatsEvent {
  const LoadStats({
    required this.userId,
    this.period = StatsPeriod.week,
  });

  final String userId;
  final StatsPeriod period;

  @override
  List<Object?> get props => [userId, period];
}

class RefreshStats extends StatsEvent {
  const RefreshStats({
    required this.userId,
    this.period = StatsPeriod.week,
  });

  final String userId;
  final StatsPeriod period;

  @override
  List<Object?> get props => [userId, period];
}

class ChangePeriod extends StatsEvent {
  const ChangePeriod({
    required this.userId,
    required this.period,
  });

  final String userId;
  final StatsPeriod period;

  @override
  List<Object?> get props => [userId, period];
}
