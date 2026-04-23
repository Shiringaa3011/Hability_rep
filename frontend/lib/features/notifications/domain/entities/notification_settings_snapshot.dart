import 'package:equatable/equatable.dart';

class NotificationSettingsSnapshot extends Equatable {
  final bool allowNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationSettingsSnapshot({
    required this.allowNotifications,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  NotificationSettingsSnapshot copyWith({
    bool? allowNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettingsSnapshot(
      allowNotifications: allowNotifications ?? this.allowNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [allowNotifications, soundEnabled, vibrationEnabled];
}
