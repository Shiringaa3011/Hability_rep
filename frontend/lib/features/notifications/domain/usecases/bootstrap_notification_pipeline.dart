import '../repositories/notifications_repository.dart';

class BootstrapNotificationPipeline {
  final NotificationsRepository _repository;

  BootstrapNotificationPipeline(this._repository);

  Future<void> call(String userId) {
    return _repository.bootstrapNotificationPipeline(userId);
  }
}
