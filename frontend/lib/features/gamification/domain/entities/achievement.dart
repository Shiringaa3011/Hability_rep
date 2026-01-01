import 'package:equatable/equatable.dart';

enum AchievementType {
  streak,
  totalHabits,
  level,
  points,
  perfectWeek;

  String get displayName {
    switch (this) {
      case AchievementType.streak:
        return 'Серия';
      case AchievementType.totalHabits:
        return 'Всего привычек';
      case AchievementType.level:
        return 'Уровень';
      case AchievementType.points:
        return 'Баллы';
      case AchievementType.perfectWeek:
        return 'Идеальная неделя';
    }
  }
}

class Achievement extends Equatable {
  const Achievement({
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

  final AchievementType type;

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

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, type: $type, '
        'isEarned: $isEarned, progress: $progress/$conditionValue)';
  }
}
