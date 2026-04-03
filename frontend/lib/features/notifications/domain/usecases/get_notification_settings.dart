import '../entities/notification_settings_snapshot.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationSettings {
  final NotificationsRepository _repository;

  GetNotificationSettings(this._repository);

  Future<NotificationSettingsSnapshot> call(String userId) =>
      _repository.getSettings(userId);
}
