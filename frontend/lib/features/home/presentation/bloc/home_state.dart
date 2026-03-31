import '../../domain/entities/today_habit_entity.dart';
import '../../domain/repositories/home_repository.dart';

class _Unset {
  const _Unset();
}

const Object _unset = _Unset();

class HomeState {
  final DateTime selectedDay;
  final String? selectedGroupId;
  final List<HomeGroupFilterOption> groupOptions;
  final List<TodayHabitEntity> habits;
  final bool isLoading;
  final String? error;

  const HomeState({
    required this.selectedDay,
    this.selectedGroupId,
    this.groupOptions = const [],
    this.habits = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    DateTime? selectedDay,
    Object? selectedGroupId = _unset,
    List<HomeGroupFilterOption>? groupOptions,
    List<TodayHabitEntity>? habits,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      selectedDay: selectedDay ?? this.selectedDay,
      selectedGroupId: identical(selectedGroupId, _unset)
          ? this.selectedGroupId
          : selectedGroupId as String?,
      groupOptions: groupOptions ?? this.groupOptions,
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
