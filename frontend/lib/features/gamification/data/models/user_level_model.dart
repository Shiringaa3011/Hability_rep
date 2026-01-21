import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_level.dart';

part 'user_level_model.freezed.dart';
part 'user_level_model.g.dart';

@freezed
class UserLevelModel with _$UserLevelModel {
  const factory UserLevelModel({
    @JsonKey(name: 'user_id') required String userId,
    required int level,
    @JsonKey(name: 'total_points') required int totalPoints,
    @JsonKey(name: 'points_to_next_level') required int pointsToNextLevel,
    @JsonKey(name: 'progress_percent') required double progressPercent,
  }) = _UserLevelModel;

  const UserLevelModel._();

  factory UserLevelModel.fromJson(Map<String, dynamic> json) =>
      _$UserLevelModelFromJson(json);

  UserLevel toEntity() {
    return UserLevel(
      userId: userId,
      level: level,
      totalPoints: totalPoints,
      pointsToNextLevel: pointsToNextLevel,
      progressPercent: progressPercent,
    );
  }

  factory UserLevelModel.fromEntity(UserLevel entity) {
    return UserLevelModel(
      userId: entity.userId,
      level: entity.level,
      totalPoints: entity.totalPoints,
      pointsToNextLevel: entity.pointsToNextLevel,
      progressPercent: entity.progressPercent,
    );
  }
}
