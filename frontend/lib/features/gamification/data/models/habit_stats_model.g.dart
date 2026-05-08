// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HabitStatsModel _$HabitStatsModelFromJson(Map<String, dynamic> json) =>
    _HabitStatsModel(
      habitId: json['habit_id'] as String,
      habitName: json['habit_name'] as String,
      totalCompletions: (json['total_completions'] as num).toInt(),
      currentStreak: (json['current_streak'] as num).toInt(),
      maxStreak: (json['max_streak'] as num).toInt(),
      totalPointsEarned: (json['total_points_earned'] as num).toInt(),
      completionRate: (json['completion_rate'] as num).toDouble(),
      missedCount: (json['missed_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$HabitStatsModelToJson(_HabitStatsModel instance) =>
    <String, dynamic>{
      'habit_id': instance.habitId,
      'habit_name': instance.habitName,
      'total_completions': instance.totalCompletions,
      'current_streak': instance.currentStreak,
      'max_streak': instance.maxStreak,
      'total_points_earned': instance.totalPointsEarned,
      'completion_rate': instance.completionRate,
      'missed_count': instance.missedCount,
    };
