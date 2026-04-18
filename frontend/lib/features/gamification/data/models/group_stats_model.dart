import '../../domain/entities/group_stats.dart';
import '../../domain/entities/user_stats.dart';

class GroupMemberStatsModel {
  const GroupMemberStatsModel({
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

  factory GroupMemberStatsModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberStatsModel(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      rank: json['rank'] as int,
      totalCompletions: json['total_completions'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      totalPoints: json['total_points'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
        'rank': rank,
        'total_completions': totalCompletions,
        'completion_rate': completionRate,
        'total_points': totalPoints,
      };

  GroupMemberStats toEntity() {
    return GroupMemberStats(
      userId: userId,
      username: username,
      rank: rank,
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      totalPoints: totalPoints,
    );
  }
}

class GroupStatsModel {
  const GroupStatsModel({
    required this.groupId,
    required this.period,
    required this.totalCompletions,
    required this.averageCompletionRate,
    required this.totalPointsGroup,
    required this.activeMembersCount,
    required this.members,
  });

  final String groupId;
  final String period;
  final int totalCompletions;
  final double averageCompletionRate;
  final int totalPointsGroup;
  final int activeMembersCount;
  final List<GroupMemberStatsModel> members;

  factory GroupStatsModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = (json['members'] as List<dynamic>?) ?? [];
    return GroupStatsModel(
      groupId: json['group_id'] as String,
      period: json['period'] as String,
      totalCompletions: json['total_completions'] as int,
      averageCompletionRate:
          (json['average_completion_rate'] as num).toDouble(),
      totalPointsGroup: json['total_points_group'] as int,
      activeMembersCount: json['active_members_count'] as int,
      members: rawMembers
          .map((m) => GroupMemberStatsModel.fromJson(
                Map<String, dynamic>.from(m as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'period': period,
        'total_completions': totalCompletions,
        'average_completion_rate': averageCompletionRate,
        'total_points_group': totalPointsGroup,
        'active_members_count': activeMembersCount,
        'members': members.map((m) => m.toJson()).toList(),
      };

  GroupStats toEntity() {
    return GroupStats(
      groupId: groupId,
      period: _periodFromString(period),
      totalCompletions: totalCompletions,
      averageCompletionRate: averageCompletionRate,
      totalPointsGroup: totalPointsGroup,
      activeMembersCount: activeMembersCount,
      members: members.map((m) => m.toEntity()).toList(),
    );
  }

  static StatsPeriod _periodFromString(String value) {
    return StatsPeriod.values.firstWhere(
      (p) => p.name == value,
      orElse: () => StatsPeriod.week,
    );
  }
}
