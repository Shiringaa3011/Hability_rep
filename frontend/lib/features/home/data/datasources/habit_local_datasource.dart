import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/today_habit_entity.dart';

abstract class HabitLocalDataSource {
  List<TodayHabitEntity>? getCachedHabits(String userId, DateTime day);
  Future<void> cacheHabits(String userId, DateTime day, List<TodayHabitEntity> habits);
  Future<void> invalidateDay(String userId, DateTime day);
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  static const String _boxName = 'habits_cache';
  late Box<String> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _box = await Hive.openBox<String>(_boxName);
    _initialized = true;
  }

  String _key(String userId, DateTime day) {
    return '${userId}_${day.year}_${day.month}_${day.day}';
  }

  @override
  List<TodayHabitEntity>? getCachedHabits(String userId, DateTime day) {
    if (!_initialized) return null;
    final key = _key(userId, day);
    final cached = _box.get(key);
    if (cached == null) return null;

    try {
      final jsonList = jsonDecode(cached) as List;
      return jsonList.map((jsonStr) => _habitFromJson(jsonDecode(jsonStr))).toList();
    } catch (e) {
      _box.delete(key);
      return null;
    }
  }

  @override
  Future<void> cacheHabits(String userId, DateTime day, List<TodayHabitEntity> habits) async {
    await init();
    final key = _key(userId, day);
    final jsonList = habits.map((h) => jsonEncode(_habitToJson(h))).toList();
    await _box.put(key, jsonEncode(jsonList));
  }

  @override
  Future<void> invalidateDay(String userId, DateTime day) async {
    if (!_initialized) return;
    final key = _key(userId, day);
    await _box.delete(key);
  }

  Map<String, dynamic> _habitToJson(TodayHabitEntity habit) {
    return {
      'id': habit.id,
      'title': habit.title,
      'description': habit.description,
      'scheduledTimeLabel': habit.scheduledTimeLabel,
      'frequencyLabel': habit.frequencyLabel,
      'completedToday': habit.completedToday,
      'groupId': habit.groupId,
      'groupName': habit.groupName,
      'remindersEnabled': habit.remindersEnabled,
      'reminderTimeLabel': habit.reminderTimeLabel,
      'dayOfWeek': habit.dayOfWeek,
    };
  }

  TodayHabitEntity _habitFromJson(Map<String, dynamic> json) {
    return TodayHabitEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledTimeLabel: json['scheduledTimeLabel'] as String?,
      frequencyLabel: json['frequencyLabel'] as String,
      completedToday: json['completedToday'] as bool? ?? false,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderTimeLabel: json['reminderTimeLabel'] as String?,
      dayOfWeek: json['dayOfWeek'] as int?,
    );
  }
}