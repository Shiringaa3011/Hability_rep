import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/notification_history_item.dart';
import '../../domain/entities/notification_settings_snapshot.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({required this.dio});

  final Dio dio;

  @override
  Future<void> bootstrapNotificationPipeline(String userId) async {
    await dio.post(
      '${ApiConstants.notificationsPath}/send',
      data: {
        'user_id': userId,
        'title': 'Добро пожаловать в Habitly',
        'body': 'Пусть этот день будет продуктивным!',
        'kind': 'info',
      },
    );
  }

  @override
  Future<List<NotificationHistoryItem>> getHistory(String userId) async {
    final response =
        await dio.get('${ApiConstants.notificationsPath}/history/$userId');
    final data = response.data as Map<String, dynamic>;
    final rows = data['items'] as List<dynamic>;
    return rows.map((raw) {
      final m = raw as Map<String, dynamic>;
      return NotificationHistoryItem(
        id: m['id'] as String,
        title: m['title'] as String,
        body: m['body'] as String,
        receivedAt: DateTime.parse(m['received_at'] as String),
        read: m['read'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<void> markRead(String notificationId) async {
    await dio.post('${ApiConstants.notificationsPath}/mark-read/$notificationId');
  }

  @override
  Future<NotificationSettingsSnapshot> getSettings(String userId) async {
    final response =
        await dio.get('${ApiConstants.notificationsPath}/settings/$userId');
    final m = response.data as Map<String, dynamic>;
    return NotificationSettingsSnapshot(
      allowNotifications: m['allow_notifications'] as bool? ?? true,
      soundEnabled: m['sound_enabled'] as bool? ?? true,
      vibrationEnabled: m['vibration_enabled'] as bool? ?? true,
    );
  }

  @override
  Future<void> saveSettings(
    String userId,
    NotificationSettingsSnapshot settings,
  ) async {
    await dio.put(
      '${ApiConstants.notificationsPath}/settings',
      data: {
        'user_id': userId,
        'allow_notifications': settings.allowNotifications,
        'sound_enabled': settings.soundEnabled,
        'vibration_enabled': settings.vibrationEnabled,
      },
    );
  }
}
