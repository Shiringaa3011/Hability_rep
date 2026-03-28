import 'package:equatable/equatable.dart';

abstract class GroupAchievementsEvent extends Equatable {
  const GroupAchievementsEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupAchievements extends GroupAchievementsEvent {
  const LoadGroupAchievements(this.groupId);

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}

class RefreshGroupAchievements extends GroupAchievementsEvent {
  const RefreshGroupAchievements(this.groupId);

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}
