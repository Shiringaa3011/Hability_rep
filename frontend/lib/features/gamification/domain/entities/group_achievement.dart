import 'package:equatable/equatable.dart';

enum GroupAchievementType {
  groupTotalHabits,
  groupAllStreak,
  groupPerfectWeek;

  String get displayName {
    switch (this) {
      case GroupAchievementType.groupTotalHabits:
        return 'Совместные привычки';
      case GroupAchievementType.groupAllStreak:
        return 'Общая серия';
      case GroupAchievementType.groupPerfectWeek:
        return 'Идеальная неделя команды';
    }
  }
}

class GroupAchievement extends Equatable {
  const GroupAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.conditionValue,
    required this.rewardPoints,
    required this.isEarned,
    required this.progress,
    required this.progressPercent,
    this.earnedAt,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final GroupAchievementType type;
  final int conditionValue;
  final int rewardPoints;
  final bool isEarned;
  final int progress;
  final double progressPercent;
  final DateTime? earnedAt;

  bool get isInProgress => !isEarned && progress > 0;
  bool get isLocked => !isEarned && progress == 0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        type,
        conditionValue,
        rewardPoints,
        isEarned,
        progress,
        progressPercent,
        earnedAt,
      ];
}
