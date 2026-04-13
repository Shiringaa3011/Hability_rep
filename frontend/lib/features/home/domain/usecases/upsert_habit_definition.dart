import '../entities/today_habit_entity.dart';
import '../repositories/home_repository.dart';

class UpsertHabitDefinition {
  final HomeRepository _repository;

  UpsertHabitDefinition(this._repository);

  Future<void> call(String userId, TodayHabitEntity habit) =>
      _repository.upsertHabitDefinition(userId, habit);
}
