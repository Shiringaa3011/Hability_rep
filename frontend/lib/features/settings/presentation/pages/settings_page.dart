import 'package:flutter/material.dart';

import '../../../notifications/presentation/pages/notification_settings_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class SettingsPage extends StatelessWidget {
  final String userId;

  const SettingsPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Профиль'),
            subtitle: const Text('Личные данные и уведомления'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfilePage(userId: userId),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Настройки уведомлений'),
            subtitle: const Text('Звук, вибрация, доставка'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => NotificationSettingsPage(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('История уведомлений'),
            subtitle: const Text('Сообщения за последние 30 дней'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfilePage(
                    userId: userId,
                    initialTab: 1,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
