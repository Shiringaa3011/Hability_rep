// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatsModelImpl _$$UserStatsModelImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsModelImpl(
      userId: json['user_id'] as String,
      period: json['period'] as String,
      totalCompletions: (json['total_completions'] as num).toInt(),
      completionRate: (json['completion_rate'] as num).toDouble(),
      currentStreak: (json['current_streak'] as num).toInt(),
      maxStreak: (json['max_streak'] as num).toInt(),
      totalPointsEarned: (json['total_points_earned'] as num).toInt(),
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$UserStatsModelImplToJson(
        _$UserStatsModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'period': instance.period,
      'total_completions': instance.totalCompletions,
      'completion_rate': instance.completionRate,
      'current_streak': instance.currentStreak,
      'max_streak': instance.maxStreak,
      'total_points_earned': instance.totalPointsEarned,
      'updated_at': instance.updatedAt,
    };
