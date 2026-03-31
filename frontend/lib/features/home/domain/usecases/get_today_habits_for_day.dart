import '../entities/today_habit_entity.dart';
import '../repositories/home_repository.dart';

class GetTodayHabitsForDay {
  final HomeRepository _repository;

  GetTodayHabitsForDay(this._repository);

  Future<List<TodayHabitEntity>> call({
    required String userId,
    required DateTime day,
    String? groupId,
  }) =>
      _repository.getHabitsForDay(userId: userId, day: day, groupId: groupId);
}
