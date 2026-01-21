import 'package:equatable/equatable.dart';

abstract class AchievementsEvent extends Equatable {
  const AchievementsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAchievements extends AchievementsEvent {
  const LoadAchievements(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class RefreshAchievements extends AchievementsEvent {
  const RefreshAchievements(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
