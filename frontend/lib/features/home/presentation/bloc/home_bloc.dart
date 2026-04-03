import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_home_group_filter_options.dart';
import '../../domain/usecases/get_today_habits_for_day.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String userId;
  final GetTodayHabitsForDay _getToday;
  final GetHomeGroupFilterOptions _getGroupOptions;
  final ToggleHabitCompletion _toggle;

  HomeBloc({
    required this.userId,
    required GetTodayHabitsForDay getToday,
    required GetHomeGroupFilterOptions getGroupOptions,
    required ToggleHabitCompletion toggle,
  })  : _getToday = getToday,
        _getGroupOptions = getGroupOptions,
        _toggle = toggle,
        super(HomeState(selectedDay: DateTime.now())) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeDateSelected>(_onDate);
    on<HomeGroupFilterSelected>(_onGroup);
    on<HomeHabitToggled>(_onToggle);
  }

  Future<void> _onLoad(HomeLoadRequested event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final options = await _getGroupOptions(userId);
      final habits = await _getToday(
        userId: userId,
        day: state.selectedDay,
        groupId: state.selectedGroupId,
      );
      emit(
        state.copyWith(
          groupOptions: options,
          habits: habits,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onDate(HomeDateSelected event, Emitter<HomeState> emit) async {
    emit(state.copyWith(selectedDay: event.day, isLoading: true, clearError: true));
    try {
      final habits = await _getToday(
        userId: userId,
        day: event.day,
        groupId: state.selectedGroupId,
      );
      emit(state.copyWith(habits: habits, isLoading: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onGroup(
    HomeGroupFilterSelected event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedGroupId: event.groupId,
        isLoading: true,
        clearError: true,
      ),
    );
    try {
      final habits = await _getToday(
        userId: userId,
        day: state.selectedDay,
        groupId: event.groupId,
      );
      emit(state.copyWith(habits: habits, isLoading: false, clearError: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onToggle(HomeHabitToggled event, Emitter<HomeState> emit) async {
    try {
      await _toggle(
        habitId: event.habitId,
        day: state.selectedDay,
        completed: event.completed,
      );
      final habits = await _getToday(
        userId: userId,
        day: state.selectedDay,
        groupId: state.selectedGroupId,
      );
      emit(state.copyWith(habits: habits, clearError: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
