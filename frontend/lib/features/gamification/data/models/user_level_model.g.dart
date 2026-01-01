// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserLevelModelImpl _$$UserLevelModelImplFromJson(Map<String, dynamic> json) =>
    _$UserLevelModelImpl(
      userId: json['user_id'] as String,
      level: (json['level'] as num).toInt(),
      totalPoints: (json['total_points'] as num).toInt(),
      pointsToNextLevel: (json['points_to_next_level'] as num).toInt(),
      progressPercent: (json['progress_percent'] as num).toDouble(),
    );

Map<String, dynamic> _$$UserLevelModelImplToJson(
        _$UserLevelModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'level': instance.level,
      'total_points': instance.totalPoints,
      'points_to_next_level': instance.pointsToNextLevel,
      'progress_percent': instance.progressPercent,
    };
