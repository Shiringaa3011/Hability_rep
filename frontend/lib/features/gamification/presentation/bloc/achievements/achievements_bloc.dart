import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_achievements.dart';
import 'achievements_event.dart';
import 'achievements_state.dart';

class AchievementsBloc extends Bloc<AchievementsEvent, AchievementsState> {
  AchievementsBloc({required this.getAchievements})
      : super(const AchievementsInitial()) {
    on<LoadAchievements>(_onLoadAchievements);
    on<RefreshAchievements>(_onRefreshAchievements);
  }

  final GetAchievements getAchievements;

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<AchievementsState> emit,
  ) async {
    emit(const AchievementsLoading());

    final result = await getAchievements(event.userId);

    result.fold(
      (failure) => emit(AchievementsError(failure.message)),
      (achievements) {
        final earnedCount = achievements.where((a) => a.isEarned).length;
        emit(AchievementsLoaded(
          achievements: achievements,
          earnedCount: earnedCount,
          totalCount: achievements.length,
        ));
      },
    );
  }

  Future<void> _onRefreshAchievements(
    RefreshAchievements event,
    Emitter<AchievementsState> emit,
  ) async {
    final currentState = state;

    final result = await getAchievements(event.userId);

    result.fold(
      (failure) {
        if (currentState is AchievementsLoaded) {
          emit(currentState);
        } else {
          emit(AchievementsError(failure.message));
        }
      },
      (achievements) {
        final earnedCount = achievements.where((a) => a.isEarned).length;
        emit(AchievementsLoaded(
          achievements: achievements,
          earnedCount: earnedCount,
          totalCount: achievements.length,
        ));
      },
    );
  }
}
