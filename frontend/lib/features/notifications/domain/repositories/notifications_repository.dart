import '../entities/notification_history_item.dart';
import '../entities/notification_settings_snapshot.dart';

abstract class NotificationsRepository {
  Future<void> bootstrapNotificationPipeline(String userId);

  Future<List<NotificationHistoryItem>> getHistory(String userId);

  Future<void> markRead(String notificationId);

  Future<NotificationSettingsSnapshot> getSettings(String userId);

  Future<void> saveSettings(
    String userId,
    NotificationSettingsSnapshot settings,
  );
}
