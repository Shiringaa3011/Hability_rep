import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_group_achievements.dart';
import 'group_achievements_event.dart';
import 'group_achievements_state.dart';

class GroupAchievementsBloc
    extends Bloc<GroupAchievementsEvent, GroupAchievementsState> {
  GroupAchievementsBloc({required this.getGroupAchievements})
      : super(const GroupAchievementsInitial()) {
    on<LoadGroupAchievements>(_onLoad);
    on<RefreshGroupAchievements>(_onRefresh);
  }

  final GetGroupAchievements getGroupAchievements;

  Future<void> _onLoad(
    LoadGroupAchievements event,
    Emitter<GroupAchievementsState> emit,
  ) async {
    emit(const GroupAchievementsLoading());

    final result = await getGroupAchievements(event.groupId);

    result.fold(
      (failure) => emit(GroupAchievementsError(failure.message)),
      (achievements) {
        final earnedCount = achievements.where((a) => a.isEarned).length;
        emit(GroupAchievementsLoaded(
          achievements: achievements,
          earnedCount: earnedCount,
          totalCount: achievements.length,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    RefreshGroupAchievements event,
    Emitter<GroupAchievementsState> emit,
  ) async {
    final currentState = state;

    final result = await getGroupAchievements(event.groupId);

    result.fold(
      (failure) {
        if (currentState is GroupAchievementsLoaded) {
          emit(currentState);
        } else {
          emit(GroupAchievementsError(failure.message));
        }
      },
      (achievements) {
        final earnedCount = achievements.where((a) => a.isEarned).length;
        emit(GroupAchievementsLoaded(
          achievements: achievements,
          earnedCount: earnedCount,
          totalCount: achievements.length,
        ));
      },
    );
  }
}
