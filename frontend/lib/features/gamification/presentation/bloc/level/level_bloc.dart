import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_user_level.dart';
import 'level_event.dart';
import 'level_state.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  LevelBloc({required this.getUserLevel}) : super(const LevelInitial()) {
    on<LoadLevel>(_onLoadLevel);
    on<RefreshLevel>(_onRefreshLevel);
  }

  final GetUserLevel getUserLevel;

  Future<void> _onLoadLevel(LoadLevel event, Emitter<LevelState> emit) async {
    emit(const LevelLoading());

    final result = await getUserLevel(event.userId);

    result.fold(
      (failure) => emit(LevelError(failure.message)),
      (level) => emit(LevelLoaded(level)),
    );
  }

  Future<void> _onRefreshLevel(RefreshLevel event, Emitter<LevelState> emit) async {
    final currentState = state;

    final result = await getUserLevel(event.userId);

    result.fold(
      (failure) {
        if (currentState is LevelLoaded) {
          emit(currentState);
        } else {
          emit(LevelError(failure.message));
        }
      },
      (level) => emit(LevelLoaded(level)),
    );
  }
}
