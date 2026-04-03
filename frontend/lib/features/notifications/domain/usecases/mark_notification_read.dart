import '../repositories/notifications_repository.dart';

class MarkNotificationRead {
  final NotificationsRepository _repository;

  MarkNotificationRead(this._repository);

  Future<void> call(String notificationId) =>
      _repository.markRead(notificationId);
}
