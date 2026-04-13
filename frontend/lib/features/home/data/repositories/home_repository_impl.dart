import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/today_habit_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../groups/domain/repositories/group_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._groups, {required this.dio});

  final GroupRepository _groups;
  final Dio dio;

  List<TodayHabitEntity> _sortedForUi(List<TodayHabitEntity> list) {
    final copy = [...list];
    copy.sort((a, b) {
      if (a.completedToday == b.completedToday) {
        return a.id.compareTo(b.id);
      }
      return a.completedToday ? 1 : -1;
    });
    return copy;
  }

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
    final mapped = rows.map((raw) {
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
    return _sortedForUi(mapped);
  }

  @override
  Future<List<HomeGroupFilterOption>> getGroupFilterOptions(String userId) async {
    final groups = await _groups.getUserGroups(userId);
    return [
      const HomeGroupFilterOption(groupId: null, title: 'Все группы'),
      ...groups.map((g) => HomeGroupFilterOption(groupId: g.id, title: g.name)),
    ];
  }

  @override
  Future<void> setHabitCompletedForDay({
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
  Future<TodayHabitEntity?> getHabitById(String habitId) async {
    try {
      final response = await dio.get('${ApiConstants.habitsPath}/$habitId');
      final m = response.data as Map<String, dynamic>;
      return TodayHabitEntity(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
        scheduledTimeLabel: m['scheduled_time'] as String?,
        frequencyLabel: (m['frequency'] as String?) == 'weekly'
            ? 'Еженедельно'
            : 'Ежедневно',
        completedToday: m['completed_today'] as bool? ?? false,
        groupId: m['group_id'] as String?,
        groupName: m['group_name'] as String?,
        remindersEnabled: m['reminders_enabled'] as bool? ?? false,
        reminderTimeLabel: m['reminder_time'] as String?,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> upsertHabitDefinition(String userId, TodayHabitEntity habit) async {
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
    if (habit.id.startsWith('h_')) {
      await dio.post(ApiConstants.habitsPath, data: payload);
    } else {
      await dio.put('${ApiConstants.habitsPath}/${habit.id}', data: payload);
    }
  }
}
