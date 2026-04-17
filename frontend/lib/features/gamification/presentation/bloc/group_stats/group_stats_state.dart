import 'package:equatable/equatable.dart';

import '../../../domain/entities/group_stats.dart';

abstract class GroupStatsState extends Equatable {
  const GroupStatsState();

  @override
  List<Object?> get props => [];
}

class GroupStatsInitial extends GroupStatsState {
  const GroupStatsInitial();
}

class GroupStatsLoading extends GroupStatsState {
  const GroupStatsLoading();
}

class GroupStatsLoaded extends GroupStatsState {
  const GroupStatsLoaded({required this.stats});

  final GroupStats stats;

  @override
  List<Object?> get props => [stats];
}

class GroupStatsError extends GroupStatsState {
  const GroupStatsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
