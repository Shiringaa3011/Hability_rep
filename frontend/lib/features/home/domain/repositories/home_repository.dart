import '../entities/today_habit_entity.dart';

class HomeGroupFilterOption {
  final String? groupId;
  final String title;

  const HomeGroupFilterOption({required this.groupId, required this.title});
}

abstract class HomeRepository {
  Future<List<TodayHabitEntity>> getHabitsForDay({
    required String userId,
    required DateTime day,
    String? groupId,
  });

  Future<List<HomeGroupFilterOption>> getGroupFilterOptions(String userId);

  Future<void> setHabitCompletedForDay({
    required String habitId,
    required DateTime day,
    required bool completed,
  });

  Future<TodayHabitEntity?> getHabitById(String habitId);

  Future<void> upsertHabitDefinition(String userId, TodayHabitEntity habit);
  Future<void> deleteHabit(String habitId, String userId);
}
