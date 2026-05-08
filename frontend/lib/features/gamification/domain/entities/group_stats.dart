import 'package:equatable/equatable.dart';

import 'user_stats.dart';

class GroupMemberStats extends Equatable {
  const GroupMemberStats({
    required this.userId,
    required this.username,
    required this.rank,
    required this.totalCompletions,
    required this.completionRate,
    required this.totalPoints,
  });

  final String userId;
  final String username;
  final int rank;
  final int totalCompletions;
  final double completionRate;
  final int totalPoints;

  @override
  List<Object?> get props => [
        userId,
        username,
        rank,
        totalCompletions,
        completionRate,
        totalPoints,
      ];
}

class GroupStats extends Equatable {
  const GroupStats({
    required this.groupId,
    required this.period,
    required this.totalCompletions,
    required this.averageCompletionRate,
    required this.totalPointsGroup,
    required this.activeMembersCount,
    required this.members,
  });

  final String groupId;
  final StatsPeriod period;
  final int totalCompletions;
  final double averageCompletionRate;
  final int totalPointsGroup;
  final int activeMembersCount;
  final List<GroupMemberStats> members;

  @override
  List<Object?> get props => [
        groupId,
        period,
        totalCompletions,
        averageCompletionRate,
        totalPointsGroup,
        activeMembersCount,
        members,
      ];
}
