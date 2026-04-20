import '../../domain/entities/notification_history_item.dart';
import '../../domain/entities/notification_settings_snapshot.dart';
import '../../domain/repositories/notifications_repository.dart';

//in-memory хранилище
class NotificationsRepositoryImpl implements NotificationsRepository {
  final List<NotificationHistoryItem> _items = [
    NotificationHistoryItem(
      id: 'n1',
      title: 'Напоминание: вода',
      body: 'Не забудьте отметить привычку «Стакан воды».',
      receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
      read: false,
    ),
    NotificationHistoryItem(
      id: 'n2',
      title: 'Новый участник в группе',
      body: 'Пётр присоединился к группе «Друзья».',
      receivedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      read: true,
    ),
    NotificationHistoryItem(
      id: 'n3',
      title: 'Серия 5 дней',
      body: 'Вы поддерживаете серию по привычке «Медитация». Так держать!',
      receivedAt: DateTime.now().subtract(const Duration(days: 2)),
      read: false,
    ),
    NotificationHistoryItem(
      id: 'n4',
      title: 'Обновление приложения',
      body: 'Доступна новая версия с улучшенной статистикой.',
      receivedAt: DateTime.now().subtract(const Duration(days: 5)),
      read: true,
    ),
  ];

  NotificationSettingsSnapshot _settings = const NotificationSettingsSnapshot(
    allowNotifications: true,
    soundEnabled: true,
    vibrationEnabled: true,
  );

  @override
  Future<List<NotificationHistoryItem>> getHistory(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    return List<NotificationHistoryItem>.from(_items)
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  @override
  Future<void> markRead(String notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final i = _items.indexWhere((e) => e.id == notificationId);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(read: true);
  }

  @override
  Future<NotificationSettingsSnapshot> getSettings(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 60));
    return _settings;
  }

  @override
  Future<void> saveSettings(
    String userId,
    NotificationSettingsSnapshot settings,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _settings = settings;
  }
}
