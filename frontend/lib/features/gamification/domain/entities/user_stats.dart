import 'package:equatable/equatable.dart';

enum StatsPeriod {
  day,
  week,
  month;

  String get displayName {
    switch (this) {
      case StatsPeriod.day:
        return 'День';
      case StatsPeriod.week:
        return 'Неделя';
      case StatsPeriod.month:
        return 'Месяц';
    }
  }
}

class UserStats extends Equatable {
  const UserStats({
    required this.userId,
    required this.period,
    required this.totalCompletions,
    required this.completionRate,
    required this.currentStreak,
    required this.maxStreak,
    required this.totalPointsEarned,
    required this.updatedAt,
  });

  final String userId;

  final StatsPeriod period;

  final int totalCompletions;

  final double completionRate;

  final int currentStreak;

  final int maxStreak;

  final int totalPointsEarned;

  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        userId,
        period,
        totalCompletions,
        completionRate,
        currentStreak,
        maxStreak,
        totalPointsEarned,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserStats(userId: $userId, period: $period, totalCompletions: $totalCompletions, '
        'completionRate: $completionRate%, currentStreak: $currentStreak)';
  }
}
