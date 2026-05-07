import 'package:equatable/equatable.dart';

class HabitStats extends Equatable {
  const HabitStats({
    required this.habitId,
    required this.habitName,
    required this.totalCompletions,
    required this.currentStreak,
    required this.maxStreak,
    required this.totalPointsEarned,
    required this.completionRate,
    this.missedCount = 0,
  });

  final String habitId;

  final String habitName;

  final int totalCompletions;

  final int currentStreak;

  final int maxStreak;

  final int totalPointsEarned;

  final double completionRate;

  final int missedCount;

  @override
  List<Object?> get props => [
        habitId,
        habitName,
        totalCompletions,
        currentStreak,
        maxStreak,
        totalPointsEarned,
        completionRate,
        missedCount,
      ];

  @override
  String toString() {
    return 'HabitStats(habitId: $habitId, name: $habitName, '
        'completions: $totalCompletions, streak: $currentStreak, missed: $missedCount)';
  }
}
