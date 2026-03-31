import '../entities/notification_settings_snapshot.dart';
import '../repositories/notifications_repository.dart';

class SaveNotificationSettings {
  final NotificationsRepository _repository;

  SaveNotificationSettings(this._repository);

  Future<void> call(String userId, NotificationSettingsSnapshot settings) =>
      _repository.saveSettings(userId, settings);
}
