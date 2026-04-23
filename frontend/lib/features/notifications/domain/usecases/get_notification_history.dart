import '../entities/notification_history_item.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationHistory {
  final NotificationsRepository _repository;

  GetNotificationHistory(this._repository);

  Future<List<NotificationHistoryItem>> call(String userId) =>
      _repository.getHistory(userId);
}
