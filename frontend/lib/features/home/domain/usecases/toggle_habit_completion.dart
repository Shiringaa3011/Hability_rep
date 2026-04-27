import '../repositories/home_repository.dart';

class ToggleHabitCompletion {
  final HomeRepository _repository;

  ToggleHabitCompletion(this._repository);

  Future<void> call({
    required String habitId,
    required String userId,
    required DateTime day,
    required bool completed,
  }) =>
      _repository.setHabitCompletedForDay(
        habitId: habitId,
        userId: userId,
        day: day,
        completed: completed,
      );
}
