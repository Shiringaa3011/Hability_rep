import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../gamification/presentation/pages/achievements_page.dart';
import '../../../gamification/presentation/pages/level_page.dart';
import '../../../gamification/presentation/pages/stats_page.dart';
import '../../../gamification/presentation/bloc/achievements/achievements_bloc.dart';
import '../../../gamification/presentation/bloc/level/level_bloc.dart';
import '../../../gamification/presentation/bloc/stats/stats_bloc.dart';
import '../../../groups/presentation/pages/groups_page.dart';
import '../../../notifications/presentation/pages/notification_history_page.dart';
import '../../../../injection_container.dart' as di;

class ProfilePage extends StatefulWidget {
  final String userId;
  final int initialTab;

  const ProfilePage({
    required this.userId,
    this.initialTab = 0,
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Разделы'),
            Tab(text: 'Уведомления'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ProfileSections(userId: widget.userId),
          NotificationHistoryPage(
            userId: widget.userId,
            wrapInScaffold: false,
          ),
        ],
      ),
    );
  }
}

class _ProfileSections extends StatelessWidget {
  final String userId;

  const _ProfileSections({required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ListTile(
          title: Text('Имя'),
          subtitle: Text('Демо-пользователь'),
        ),
        const ListTile(
          title: Text('Почта'),
          subtitle: Text('user@example.com'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Индивидуальная статистика'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
                create: (_) => di.sl<StatsBloc>(),
                child: StatsPage(userId: userId),
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.emoji_events_outlined),
          title: const Text('Уровень'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
                create: (_) => di.sl<LevelBloc>(),
                child: LevelPage(userId: userId),
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.stars_outlined),
          title: const Text('Достижения'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
                create: (_) => di.sl<AchievementsBloc>(),
                child: AchievementsPage(userId: userId),
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.groups_outlined),
          title: const Text('Группы'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => GroupsPage(userId: userId),
            ),
          ),
        ),
      ],
    );
  }
}
