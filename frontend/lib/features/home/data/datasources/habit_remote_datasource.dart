import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/today_habit_entity.dart';

abstract class HabitRemoteDataSource {
  Future<List<TodayHabitEntity>> getHabitsForDay({
    required String userId,
    required DateTime day,
    String? groupId,
  });
  Future<void> setHabitCompleted({
    required String habitId,
    required DateTime day,
    required bool completed,
  });
  Future<void> upsertHabit(String userId, TodayHabitEntity habit);
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  final Dio dio;

  HabitRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodayHabitEntity>> getHabitsForDay({
    required String userId,
    required DateTime day,
    String? groupId,
  }) async {
    final response = await dio.get(
      '${ApiConstants.habitsPath}/user/$userId/day',
      queryParameters: {
        'day': day.toIso8601String().split('T').first,
        if (groupId != null) 'group_id': groupId,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final rows = data['habits'] as List<dynamic>;
    return rows.map((raw) {
      final m = raw as Map<String, dynamic>;
      final frequency = (m['frequency'] as String?) == 'weekly'
          ? 'Еженедельно'
          : 'Ежедневно';
      return TodayHabitEntity(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
        scheduledTimeLabel: m['scheduled_time'] as String?,
        frequencyLabel: frequency,
        completedToday: m['completed_today'] as bool? ?? false,
        groupId: m['group_id'] as String?,
        groupName: m['group_name'] as String?,
        remindersEnabled: m['reminders_enabled'] as bool? ?? false,
        reminderTimeLabel: m['reminder_time'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> setHabitCompleted({
    required String habitId,
    required DateTime day,
    required bool completed,
  }) async {
    await dio.post(
      '${ApiConstants.habitsPath}/$habitId/completion',
      data: {
        'day': day.toIso8601String().split('T').first,
        'completed': completed,
      },
    );
  }

  @override
  Future<void> upsertHabit(String userId, TodayHabitEntity habit) async {
    final frequency = (habit.frequencyLabel == 'Еженедельно') ? 'weekly' : 'daily';
    final payload = {
      'user_id': userId,
      'title': habit.title,
      'description': habit.description,
      'group_id': habit.groupId,
      'frequency': frequency,
      'scheduled_time': habit.scheduledTimeLabel,
      'reminders_enabled': habit.remindersEnabled,
      'reminder_time': habit.reminderTimeLabel,
    };
    if (frequency == 'weekly' && habit.dayOfWeek != null) {
      payload['day_of_week'] = habit.dayOfWeek;
    }
    if (habit.id.startsWith('h_')) {
      await dio.post(ApiConstants.habitsPath, data: payload);
    } else {
      await dio.put('${ApiConstants.habitsPath}/${habit.id}', data: payload);
    }
  }
}