import '../entities/today_habit_entity.dart';
import '../repositories/home_repository.dart';

class GetHabitById {
  final HomeRepository _repository;

  GetHabitById(this._repository);

  Future<TodayHabitEntity?> call(String habitId) => _repository.getHabitById(habitId);
}
