import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/achievement.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
class AchievementModel with _$AchievementModel {
  const factory AchievementModel({
    required String id,
    required String name,
    required String description,
    required String icon,
    required String type,
    @JsonKey(name: 'condition_value') required int conditionValue,
    @JsonKey(name: 'reward_points') required int rewardPoints,
    @JsonKey(name: 'is_earned') required bool isEarned,
    required int progress,
    @JsonKey(name: 'progress_percent') required double progressPercent,
    @JsonKey(name: 'earned_at') String? earnedAt,
  }) = _AchievementModel;

  const AchievementModel._();

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);

  Achievement toEntity() {
    return Achievement(
      id: id,
      name: name,
      description: description,
      icon: icon,
      type: _parseType(type),
      conditionValue: conditionValue,
      rewardPoints: rewardPoints,
      isEarned: isEarned,
      progress: progress,
      progressPercent: progressPercent,
      earnedAt: earnedAt != null ? DateTime.parse(earnedAt!) : null,
    );
  }

  factory AchievementModel.fromEntity(Achievement entity) {
    return AchievementModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      type: entity.type.name,
      conditionValue: entity.conditionValue,
      rewardPoints: entity.rewardPoints,
      isEarned: entity.isEarned,
      progress: entity.progress,
      progressPercent: entity.progressPercent,
      earnedAt: entity.earnedAt?.toIso8601String(),
    );
  }

  static AchievementType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'streak':
        return AchievementType.streak;
      case 'total_habits':
        return AchievementType.totalHabits;
      case 'level':
        return AchievementType.level;
      case 'points':
        return AchievementType.points;
      case 'perfect_week':
        return AchievementType.perfectWeek;
      default:
        return AchievementType.streak;
    }
  }
}
