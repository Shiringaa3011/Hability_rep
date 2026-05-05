import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/get_home_group_filter_options.dart';
import '../../domain/usecases/get_today_habits_for_day.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../../gamification/domain/usecases/complete_habit.dart';
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
    if (state.habits.isEmpty) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final options = await _getGroupOptions(userId);
      final habits = await _getToday(
        userId: userId,
        day: state.selectedDay,
        groupId: state.selectedGroupId,
      );
      emit(state.copyWith(
        groupOptions: options,
        habits: habits,
        isLoading: false,
        isOffline: false,
        clearError: true,
      ));
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      emit(state.copyWith(
        isLoading: false,
        isOffline: isOffline,
        error: state.habits.isEmpty ? fromDioException(e).message : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: state.habits.isEmpty ? 'Что-то пошло не так' : null,
      ));
    }
  }

  Future<void> _onDate(HomeDateSelected event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      selectedDay: event.day,
      habits: const [],
      isLoading: true,
      clearError: true,
    ));

    try {
      final habits = await _getToday(
        userId: userId,
        day: event.day,
        groupId: state.selectedGroupId,
      );
      emit(state.copyWith(habits: habits, isLoading: false, clearError: true));
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      emit(state.copyWith(
        isLoading: false,
        isOffline: isOffline,
        error: fromDioException(e).message,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Что-то пошло не так'));
    }
  }

  Future<void> _onGroup(HomeGroupFilterSelected event, Emitter<HomeState> emit) async {
    emit(state.copyWith(
      selectedGroupId: event.groupId,
      isLoading: true,
      clearError: true,
    ));
    try {
      final habits = await _getToday(
        userId: userId,
        day: state.selectedDay,
        groupId: event.groupId,
      );
      emit(state.copyWith(habits: habits, isLoading: false, clearError: true));
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      emit(state.copyWith(
        isLoading: false,
        isOffline: isOffline,
        error: fromDioException(e).message,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Что-то пошло не так'));
    }
  }

  Future<void> _onToggle(HomeHabitToggled event, Emitter<HomeState> emit) async {
    final oldHabits = state.habits;

    emit(state.copyWith(
      habits: state.habits.map((h) {
        if (h.id == event.habitId) return h.copyWith(completedToday: event.completed);
        return h;
      }).toList(),
    ));

    try {
      if (event.completed) {
        final result = await _completeHabit(
          CompleteHabitParams(
            habitId: event.habitId,
            userId: userId,
            completionDate: state.selectedDay,
          ),
        );
        result.fold(
          (failure) => emit(state.copyWith(habits: oldHabits, error: failure.message)),
          (_) => null,
        );
      } else {
        await _toggle(
          habitId: event.habitId,
          userId: userId,
          day: state.selectedDay,
          completed: false,
        );
      }

      final freshHabits = await _getToday(
        userId: userId,
        day: state.selectedDay,
        groupId: state.selectedGroupId,
        forceRefresh: true,
      );
      emit(state.copyWith(habits: freshHabits, clearError: true));
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      emit(state.copyWith(
        habits: oldHabits,
        isOffline: isOffline,
        error: isOffline ? 'Нет подключения к интернету' : fromDioException(e).message,
      ));
    } catch (e) {
      emit(state.copyWith(habits: oldHabits, error: 'Что-то пошло не так'));
    }
  }
}