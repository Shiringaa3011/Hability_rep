import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/entities/notification_settings_snapshot.dart';
import '../cubit/notification_settings_cubit.dart';

class NotificationSettingsPage extends StatelessWidget {
  final String userId;

  const NotificationSettingsPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationSettingsCubit(
        userId: userId,
        getSettings: di.sl(),
        saveSettings: di.sl(),
      )..load(),
      child: const _NotificationSettingsView(),
    );
  }
}

class _NotificationSettingsView extends StatelessWidget {
  const _NotificationSettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: BlocBuilder<NotificationSettingsCubit, NotificationSettingsSnapshot>(
        builder: (context, s) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Отправлять уведомления'),
                subtitle: const Text(
                  'Глобальный переключатель доставки push и in-app',
                ),
                value: s.allowNotifications,
                onChanged: (v) =>
                    context.read<NotificationSettingsCubit>().setAllow(v),
              ),
              SwitchListTile(
                title: const Text('Звук'),
                subtitle: const Text('Звуковой сигнал при получении'),
                value: s.soundEnabled,
                onChanged: s.allowNotifications
                    ? (v) => context.read<NotificationSettingsCubit>().setSound(v)
                    : null,
              ),
              SwitchListTile(
                title: const Text('Вибрация'),
                subtitle: const Text('Тактильный отклик при получении'),
                value: s.vibrationEnabled,
                onChanged: s.allowNotifications
                    ? (v) =>
                        context.read<NotificationSettingsCubit>().setVibration(v)
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
