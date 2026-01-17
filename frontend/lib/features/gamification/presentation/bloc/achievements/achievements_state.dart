import 'package:equatable/equatable.dart';

import '../../../domain/entities/achievement.dart';

abstract class AchievementsState extends Equatable {
  const AchievementsState();

  @override
  List<Object?> get props => [];
}

class AchievementsInitial extends AchievementsState {
  const AchievementsInitial();
}

class AchievementsLoading extends AchievementsState {
  const AchievementsLoading();
}

class AchievementsLoaded extends AchievementsState {
  const AchievementsLoaded({
    required this.achievements,
    required this.earnedCount,
    required this.totalCount,
  });

  final List<Achievement> achievements;
  final int earnedCount;
  final int totalCount;

  @override
  List<Object?> get props => [achievements, earnedCount, totalCount];
}

class AchievementsError extends AchievementsState {
  const AchievementsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
