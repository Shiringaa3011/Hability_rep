import 'package:equatable/equatable.dart';

import '../../../domain/entities/group_achievement.dart';

abstract class GroupAchievementsState extends Equatable {
  const GroupAchievementsState();

  @override
  List<Object?> get props => [];
}

class GroupAchievementsInitial extends GroupAchievementsState {
  const GroupAchievementsInitial();
}

class GroupAchievementsLoading extends GroupAchievementsState {
  const GroupAchievementsLoading();
}

class GroupAchievementsLoaded extends GroupAchievementsState {
  const GroupAchievementsLoaded({
    required this.achievements,
    required this.earnedCount,
    required this.totalCount,
  });

  final List<GroupAchievement> achievements;
  final int earnedCount;
  final int totalCount;

  @override
  List<Object?> get props => [achievements, earnedCount, totalCount];
}

class GroupAchievementsError extends GroupAchievementsState {
  const GroupAchievementsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
