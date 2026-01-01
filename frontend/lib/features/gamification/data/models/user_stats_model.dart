import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_stats.dart';

part 'user_stats_model.freezed.dart';
part 'user_stats_model.g.dart';

@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    @JsonKey(name: 'user_id') required String userId,
    required String period,
    @JsonKey(name: 'total_completions') required int totalCompletions,
    @JsonKey(name: 'completion_rate') required double completionRate,
    @JsonKey(name: 'current_streak') required int currentStreak,
    @JsonKey(name: 'max_streak') required int maxStreak,
    @JsonKey(name: 'total_points_earned') required int totalPointsEarned,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _UserStatsModel;

  const UserStatsModel._();

  factory UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);

  UserStats toEntity() {
    return UserStats(
      userId: userId,
      period: _parsePeriod(period),
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      totalPointsEarned: totalPointsEarned,
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory UserStatsModel.fromEntity(UserStats entity) {
    return UserStatsModel(
      userId: entity.userId,
      period: entity.period.name,
      totalCompletions: entity.totalCompletions,
      completionRate: entity.completionRate,
      currentStreak: entity.currentStreak,
      maxStreak: entity.maxStreak,
      totalPointsEarned: entity.totalPointsEarned,
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  static StatsPeriod _parsePeriod(String period) {
    switch (period.toLowerCase()) {
      case 'day':
        return StatsPeriod.day;
      case 'week':
        return StatsPeriod.week;
      case 'month':
        return StatsPeriod.month;
      default:
        return StatsPeriod.week;
    }
  }
}
