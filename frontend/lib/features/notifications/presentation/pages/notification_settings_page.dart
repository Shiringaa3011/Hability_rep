import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/entities/notification_settings_snapshot.dart';
import '../cubit/notification_settings_cubit.dart';

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: BlocBuilder<NotificationSettingsCubit, NotificationSettingsSnapshot>(
        builder: (context, s) {
          final isEnabled = s.allowNotifications;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Отправлять уведомления'),
                subtitle: const Text('Глобальный переключатель доставки push и in-app'),
                value: s.allowNotifications,
                onChanged: (v) => context.read<NotificationSettingsCubit>().setAllow(v),
                activeColor: colors.primary,
              ),
              SwitchListTile(
                title: Text(
                  'Звук',
                  style: TextStyle(color: isEnabled ? colors.foreground : colors.mutedForeground),
                ),
                subtitle: Text(
                  'Звуковой сигнал при получении',
                  style: TextStyle(color: isEnabled ? colors.mutedForeground : colors.mutedForeground.withValues(alpha: 0.5)),
                ),
                value: s.soundEnabled,
                onChanged: isEnabled
                    ? (v) => context.read<NotificationSettingsCubit>().setSound(v)
                    : null,
                activeColor: colors.primary,
                inactiveThumbColor: colors.mutedForeground,
                inactiveTrackColor: colors.muted,
              ),
              SwitchListTile(
                title: Text(
                  'Вибрация',
                  style: TextStyle(color: isEnabled ? colors.foreground : colors.mutedForeground),
                ),
                subtitle: Text(
                  'Тактильный отклик при получении',
                  style: TextStyle(color: isEnabled ? colors.mutedForeground : colors.mutedForeground.withValues(alpha: 0.5)),
                ),
                value: s.vibrationEnabled,
                onChanged: isEnabled
                    ? (v) => context.read<NotificationSettingsCubit>().setVibration(v)
                    : null,
                activeColor: colors.primary,
                inactiveThumbColor: colors.mutedForeground,
                inactiveTrackColor: colors.muted,
              ),
            ],
          );
        },
      ),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  final String userId;

  const NotificationSettingsPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationSettingsCubit(
        userId: userId,
        bootstrapPipeline: di.sl(),
        getSettings: di.sl(),
        saveSettings: di.sl(),
      )..load(),
      child: const _NotificationSettingsView(),
    );
  }
}