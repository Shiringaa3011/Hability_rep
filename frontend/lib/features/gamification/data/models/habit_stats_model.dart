import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/habit_stats.dart';

part 'habit_stats_model.freezed.dart';
part 'habit_stats_model.g.dart';

@freezed
abstract class HabitStatsModel with _$HabitStatsModel {
  const factory HabitStatsModel({
    @JsonKey(name: 'habit_id') required String habitId,
    @JsonKey(name: 'habit_name') required String habitName,
    @JsonKey(name: 'total_completions') required int totalCompletions,
    @JsonKey(name: 'current_streak') required int currentStreak,
    @JsonKey(name: 'max_streak') required int maxStreak,
    @JsonKey(name: 'total_points_earned') required int totalPointsEarned,
    @JsonKey(name: 'completion_rate') required double completionRate,
    @JsonKey(name: 'missed_count') @Default(0) int missedCount,
  }) = _HabitStatsModel;

  const HabitStatsModel._();

  factory HabitStatsModel.fromJson(Map<String, dynamic> json) =>
      _$HabitStatsModelFromJson(json);

  HabitStats toEntity() {
    return HabitStats(
      habitId: habitId,
      habitName: habitName,
      totalCompletions: totalCompletions,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      totalPointsEarned: totalPointsEarned,
      completionRate: completionRate,
      missedCount: missedCount,
    );
  }

  factory HabitStatsModel.fromEntity(HabitStats entity) {
    return HabitStatsModel(
      habitId: entity.habitId,
      habitName: entity.habitName,
      totalCompletions: entity.totalCompletions,
      currentStreak: entity.currentStreak,
      maxStreak: entity.maxStreak,
      totalPointsEarned: entity.totalPointsEarned,
      completionRate: entity.completionRate,
      missedCount: entity.missedCount,
    );
  }
}
