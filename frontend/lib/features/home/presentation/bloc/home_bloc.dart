import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_home_group_filter_options.dart';
import '../../domain/usecases/get_today_habits_for_day.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../../gamification/domain/usecases/complete_habit.dart';
import '../../../gamification/domain/entities/achievement.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String userId;
  final GetTodayHabitsForDay _getToday;
  final GetHomeGroupFilterOptions _getGroupOptions;
  final ToggleHabitCompletion _toggle;
  final CompleteHabit _completeHabit;

  HomeBloc({
    required this.userId,
    required GetTodayHabitsForDay getToday,
    required GetHomeGroupFilterOptions getGroupOptions,
    required ToggleHabitCompletion toggle,
    required CompleteHabit completeHabit,
  })  : _getToday = getToday,
        _getGroupOptions = getGroupOptions,
        _toggle = toggle,
        _completeHabit = completeHabit,
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
    final oldHabits = state.habits;

    final updatedHabits = state.habits.map((h) {
      if (h.id == event.habitId) {
        return h.copyWith(completedToday: event.completed);
      }
      return h;
    }).toList();
    
    emit(state.copyWith(habits: updatedHabits));
    
    try {
      await _toggle(
        habitId: event.habitId,
        day: state.selectedDay,
        completed: event.completed,
      );
      
      if (event.completed) {
        try {
          final newAchievements = await _completeHabit(
            CompleteHabitParams(
              habitId: event.habitId,
              userId: userId,
            ),
          );

          newAchievements.fold(
            (failure) => null,
            (achievements) {
              if (achievements.isNotEmpty) {
              }
            },
          );
        } catch (_) {
        }
      }
      final freshHabits = await _getToday(
        userId: userId,
        day: state.selectedDay,
        groupId: state.selectedGroupId,
      );
      emit(state.copyWith(habits: freshHabits));
    } catch (e) {
      emit(state.copyWith(habits: oldHabits, error: e.toString()));
    }
  }
}