import 'package:equatable/equatable.dart';

class UserLevel extends Equatable {
  const UserLevel({
    required this.userId,
    required this.level,
    required this.totalPoints,
    required this.pointsToNextLevel,
    required this.progressPercent,
  });

  final String userId;

  final int level;

  final int totalPoints;

  final int pointsToNextLevel;

  final double progressPercent;

  @override
  List<Object?> get props => [
        userId,
        level,
        totalPoints,
        pointsToNextLevel,
        progressPercent,
      ];

  @override
  String toString() {
    return 'UserLevel(userId: $userId, level: $level, totalPoints: $totalPoints, '
        'pointsToNextLevel: $pointsToNextLevel, progressPercent: $progressPercent)';
  }
}
