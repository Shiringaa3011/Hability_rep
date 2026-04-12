import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_settings_snapshot.dart';
import '../../domain/usecases/bootstrap_notification_pipeline.dart';
import '../../domain/usecases/get_notification_settings.dart';
import '../../domain/usecases/save_notification_settings.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsSnapshot> {
  NotificationSettingsCubit({
    required this.userId,
    required BootstrapNotificationPipeline bootstrapPipeline,
    required GetNotificationSettings getSettings,
    required SaveNotificationSettings saveSettings,
  })  : _bootstrapPipeline = bootstrapPipeline,
        _getSettings = getSettings,
        _saveSettings = saveSettings,
        super(
          const NotificationSettingsSnapshot(
            allowNotifications: true,
            soundEnabled: true,
            vibrationEnabled: true,
          ),
        );

  final String userId;
  final BootstrapNotificationPipeline _bootstrapPipeline;
  final GetNotificationSettings _getSettings;
  final SaveNotificationSettings _saveSettings;

  Future<void> load() async {
    await _bootstrapPipeline(userId);
    final s = await _getSettings(userId);
    emit(s);
  }

  Future<void> setAllow(bool v) async {
    final next = state.copyWith(allowNotifications: v);
    await _saveSettings(userId, next);
    emit(next);
  }

  Future<void> setSound(bool v) async {
    final next = state.copyWith(soundEnabled: v);
    await _saveSettings(userId, next);
    emit(next);
  }

  Future<void> setVibration(bool v) async {
    final next = state.copyWith(vibrationEnabled: v);
    await _saveSettings(userId, next);
    emit(next);
  }
}
