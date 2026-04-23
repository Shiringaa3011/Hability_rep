import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../bloc/achievements/achievements_bloc.dart';
import '../bloc/group_achievements/group_achievements_bloc.dart';
import '../bloc/level/level_bloc.dart';
import '../bloc/stats/stats_bloc.dart';
import 'achievements_page.dart';
import 'group_achievements_page.dart';
import 'level_page.dart';
import 'stats_page.dart';

class StatsHubPage extends StatelessWidget {
  final String userId;

  const StatsHubPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика и прогресс')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubTile(
            icon: Icons.insights,
            title: 'Сводная статистика',
            subtitle: 'Выполнения, процент, серии, баллы',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<StatsBloc>(),
                  child: StatsPage(userId: userId),
                ),
              ),
            ),
          ),
          _HubTile(
            icon: Icons.emoji_events_outlined,
            title: 'Уровень',
            subtitle: 'Прогресс и очки до следующего уровня',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<LevelBloc>(),
                  child: LevelPage(userId: userId),
                ),
              ),
            ),
          ),
          _HubTile(
            icon: Icons.stars_outlined,
            title: 'Достижения',
            subtitle: 'Личные награды и прогресс',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<AchievementsBloc>(),
                  child: AchievementsPage(userId: userId),
                ),
              ),
            ),
          ),
          _HubTile(
            icon: Icons.groups_2_outlined,
            title: 'Групповые достижения',
            subtitle: 'Награды выбранной группы (демо: «Семья»)',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<GroupAchievementsBloc>(),
                  child: const GroupAchievementsPage(groupId: '1'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
