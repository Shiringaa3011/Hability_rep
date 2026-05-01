// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AchievementModel _$AchievementModelFromJson(Map<String, dynamic> json) =>
    _AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: json['type'] as String,
      conditionValue: (json['condition_value'] as num).toInt(),
      rewardPoints: (json['reward_points'] as num).toInt(),
      isEarned: json['is_earned'] as bool,
      progress: (json['progress'] as num).toInt(),
      progressPercent: (json['progress_percent'] as num).toDouble(),
      earnedAt: json['earned_at'] as String?,
    );

Map<String, dynamic> _$AchievementModelToJson(_AchievementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'type': instance.type,
      'condition_value': instance.conditionValue,
      'reward_points': instance.rewardPoints,
      'is_earned': instance.isEarned,
      'progress': instance.progress,
      'progress_percent': instance.progressPercent,
      'earned_at': instance.earnedAt,
    };
