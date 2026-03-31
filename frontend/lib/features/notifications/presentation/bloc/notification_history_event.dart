abstract class NotificationHistoryEvent {}

class NotificationHistoryLoad extends NotificationHistoryEvent {
  final String userId;

  NotificationHistoryLoad(this.userId);
}

class NotificationHistoryMarkRead extends NotificationHistoryEvent {
  final String id;

  NotificationHistoryMarkRead(this.id);
}
