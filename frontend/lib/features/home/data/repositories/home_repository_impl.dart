import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/today_habit_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../datasources/habit_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(
    this._groups, {
    required this.dio,
    required this.localDataSource,
  });

  final GroupRepository _groups;
  final Dio dio;
  final HabitLocalDataSource localDataSource;

  List<TodayHabitEntity> _sortedForUi(List<TodayHabitEntity> list) {
    final copy = [...list];
    copy.sort((a, b) {
      if (a.completedToday == b.completedToday) return a.id.compareTo(b.id);
      return a.completedToday ? 1 : -1;
    });
    return copy;
  }

  List<TodayHabitEntity> _filterByGroup(List<TodayHabitEntity> habits, String? groupId) {
    if (groupId == null) return habits;
    return habits.where((h) => h.groupId == groupId).toList();
  }

  List<TodayHabitEntity> _mapResponse(Map<String, dynamic> data) {
    final rows = data['habits'] as List<dynamic>;
    return rows.map((raw) {
      final m = raw as Map<String, dynamic>;
      return TodayHabitEntity(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
        scheduledTimeLabel: m['scheduled_time'] as String?,
        frequencyLabel: (m['frequency'] as String?) == 'weekly' ? 'Еженедельно' : 'Ежедневно',
        completedToday: m['completed_today'] as bool? ?? false,
        groupId: m['group_id'] as String?,
        groupName: m['group_name'] as String?,
        remindersEnabled: m['reminders_enabled'] as bool? ?? false,
        reminderTimeLabel: m['reminder_time'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<TodayHabitEntity>> getHabitsForDay({
    required String userId,
    required DateTime day,
    String? groupId,
    bool forceRefresh = false,
  }) async {
    final cached = forceRefresh ? null : localDataSource.getCachedHabits(userId, day);

    if (cached != null) {
      _refreshCache(userId, day).ignore();
      return _filterByGroup(cached, groupId);
    }

    try {
      final response = await dio.get(
        '${ApiConstants.habitsPath}/user/$userId/day',
        queryParameters: {
          'day': day.toIso8601String().split('T').first,
        },
      );
      final sorted = _sortedForUi(_mapResponse(response.data as Map<String, dynamic>));
      await localDataSource.cacheHabits(userId, day, sorted);
      return _filterByGroup(sorted, groupId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _refreshCache(String userId, DateTime day) async {
    try {
      final response = await dio.get(
        '${ApiConstants.habitsPath}/user/$userId/day',
        queryParameters: {
          'day': day.toIso8601String().split('T').first,
        },
      );
      final sorted = _sortedForUi(_mapResponse(response.data as Map<String, dynamic>));
      await localDataSource.cacheHabits(userId, day, sorted);
    } catch (_) {
    }
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
    String? userId,
  }) async {
    await dio.post(
      '${ApiConstants.habitsPath}/$habitId/completion',
      data: {
        'day': day.toIso8601String().split('T').first,
        'completed': completed,
        'user_id': userId,
      },
    );
    if (userId != null) {
      await localDataSource.invalidateDay(userId, day);
    }
  }

  @override
  Future<TodayHabitEntity?> getHabitById(String habitId, String userId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.habitsPath}/$habitId',
        queryParameters: {'user_id': userId},
      );
      final m = response.data as Map<String, dynamic>;
      return TodayHabitEntity(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
        scheduledTimeLabel: m['scheduled_time'] as String?,
        frequencyLabel: (m['frequency'] as String?) == 'weekly' ? 'Еженедельно' : 'Ежедневно',
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

    if (frequency == 'weekly' && habit.dayOfWeek != null) {
      payload['day_of_week'] = habit.dayOfWeek;
    }

    if (habit.id.startsWith('h_')) {
      await dio.post(ApiConstants.habitsPath, data: payload);
    } else {
      await dio.put('${ApiConstants.habitsPath}/${habit.id}', data: payload);
    }

    await localDataSource.invalidateDay(userId, DateTime.now());
  }

  @override
  Future<void> deleteHabit(String habitId, String userId) async {
    await dio.delete(
      '${ApiConstants.habitsPath}/$habitId',
      queryParameters: {'user_id': userId},
    );

    await localDataSource.invalidateDay(userId, DateTime.now());
  }
}
