import '../../../../core/error/exceptions.dart';
import '../../domain/entities/today_habit_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../../../gamification/data/datasources/gamification_remote_datasource.dart';
import '../../../groups/domain/repositories/group_repository.dart';

// локальное хранилище привычек на главном экране + фильтр групп из GroupRepository
// данные живут в памяти процесса; выполнение привычки пишется в реальный API
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._groups, this._gamification);

  final GroupRepository _groups;
  final GamificationRemoteDataSource _gamification;

  final List<TodayHabitEntity> _catalog = [
    TodayHabitEntity(
      id: '00000000-0000-0000-0000-000000000002',
      title: 'Утренняя зарядка',
      description: '10 минут разминки',
      scheduledTimeLabel: '08:00',
      frequencyLabel: 'Ежедневно',
      groupId: '1',
      groupName: 'Семья',
      remindersEnabled: true,
      reminderTimeLabel: '07:45',
    ),
    TodayHabitEntity(
      id: '00000000-0000-0000-0000-000000000003',
      title: 'Стакан воды после пробуждения',
      description: null,
      scheduledTimeLabel: '08:10',
      frequencyLabel: 'Ежедневно',
      groupId: '1',
      groupName: 'Семья',
      remindersEnabled: false,
    ),
    TodayHabitEntity(
      id: '00000000-0000-0000-0000-000000000004',
      title: 'Чтение 20 минут',
      description: 'Книга или статьи',
      scheduledTimeLabel: '21:00',
      frequencyLabel: 'Ежедневно',
      groupId: null,
      groupName: 'Личное',
      remindersEnabled: true,
      reminderTimeLabel: '20:30',
    ),
    TodayHabitEntity(
      id: '00000000-0000-0000-0000-000000000005',
      title: 'Медитация',
      description: null,
      scheduledTimeLabel: '07:30',
      frequencyLabel: 'Ежедневно',
      groupId: '2',
      groupName: 'Друзья',
      remindersEnabled: false,
    ),
    TodayHabitEntity(
      id: '00000000-0000-0000-0000-000000000006',
      title: 'Прогулка 6000 шагов',
      description: null,
      scheduledTimeLabel: null,
      frequencyLabel: 'Ежедневно',
      groupId: '2',
      groupName: 'Друзья',
      remindersEnabled: true,
      reminderTimeLabel: '18:00',
    ),
  ];

  final Set<String> _completedKeys = {};

  String _dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

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
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final keyDate = _dayKey(day);
    Iterable<TodayHabitEntity> list = _catalog;
    if (groupId != null) {
      list = list.where((h) => h.groupId == groupId);
    }
    final mapped = list
        .map(
          (h) => h.copyWith(
            completedToday: _completedKeys.contains('${h.id}|$keyDate'),
          ),
        )
        .toList();
    return _sortedForUi(mapped);
  }

  @override
  Future<List<HomeGroupFilterOption>> getGroupFilterOptions(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final groups = await _groups.getUserGroups(userId);
    return [
      const HomeGroupFilterOption(groupId: null, title: 'Все группы'),
      ...groups.map((g) => HomeGroupFilterOption(groupId: g.id, title: g.name)),
    ];
  }

  @override
  Future<void> setHabitCompletedForDay({
    required String habitId,
    required String userId,
    required DateTime day,
    required bool completed,
  }) async {
    final k = '${habitId}|${_dayKey(day)}';
    if (completed) {
      if (!_completedKeys.contains(k)) {
        try {
          await _gamification.completeHabit(habitId, userId);
        } on ServerException catch (e) {
          if (!e.message.contains('already completed')) rethrow;
        }
        _completedKeys.add(k);
      }
    } else {
      _completedKeys.remove(k);
    }
  }

  @override
  Future<TodayHabitEntity?> getHabitById(String habitId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    try {
      return _catalog.firstWhere((h) => h.id == habitId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertHabitDefinition(TodayHabitEntity habit) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final i = _catalog.indexWhere((h) => h.id == habit.id);
    final clean = habit.copyWith(completedToday: false);
    if (i >= 0) {
      _catalog[i] = clean;
    } else {
      _catalog.add(clean);
    }
  }
}
