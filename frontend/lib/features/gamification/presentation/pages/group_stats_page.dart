import 'package:flutter/material.dart';

class GroupStatsPage extends StatelessWidget {
  const GroupStatsPage({
    required this.groupId,
    super.key,
  });

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика группы'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.groups,
                size: 64,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Групповая статистика',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Эта функция будет реализована\nпосле создания модуля групп',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'ID группы: $groupId',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
