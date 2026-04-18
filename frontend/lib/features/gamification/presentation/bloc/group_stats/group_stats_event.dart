import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_stats.dart';

abstract class GroupStatsEvent extends Equatable {
  const GroupStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupStats extends GroupStatsEvent {
  const LoadGroupStats({
    required this.groupId,
    this.period = StatsPeriod.week,
  });

  final String groupId;
  final StatsPeriod period;

  @override
  List<Object?> get props => [groupId, period];
}

class RefreshGroupStats extends GroupStatsEvent {
  const RefreshGroupStats({
    required this.groupId,
    required this.period,
  });

  final String groupId;
  final StatsPeriod period;

  @override
  List<Object?> get props => [groupId, period];
}

class ChangeGroupStatsPeriod extends GroupStatsEvent {
  const ChangeGroupStatsPeriod({
    required this.groupId,
    required this.period,
  });

  final String groupId;
  final StatsPeriod period;

  @override
  List<Object?> get props => [groupId, period];
}
