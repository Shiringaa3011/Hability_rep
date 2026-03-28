import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/group_achievement.dart';
import '../bloc/group_achievements/group_achievements_bloc.dart';
import '../bloc/group_achievements/group_achievements_event.dart';
import '../bloc/group_achievements/group_achievements_state.dart';

class GroupAchievementsPage extends StatefulWidget {
  const GroupAchievementsPage({
    required this.groupId,
    super.key,
  });

  final String groupId;

  @override
  State<GroupAchievementsPage> createState() => _GroupAchievementsPageState();
}

class _GroupAchievementsPageState extends State<GroupAchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    context.read<GroupAchievementsBloc>().add(
          LoadGroupAchievements(widget.groupId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Награды группы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GroupAchievementsBloc>().add(
                    RefreshGroupAchievements(widget.groupId),
                  );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Все'),
            Tab(text: 'Получено'),
            Tab(text: 'В процессе'),
          ],
        ),
      ),
      body: BlocBuilder<GroupAchievementsBloc, GroupAchievementsState>(
        builder: (context, state) {
          if (state is GroupAchievementsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GroupAchievementsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _load, child: const Text('Повторить')),
                ],
              ),
            );
          }

          if (state is GroupAchievementsLoaded) {
            return Column(
              children: [
                _buildProgressBanner(state, theme),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(state.achievements, theme),
                      _buildList(
                        state.achievements.where((a) => a.isEarned).toList(),
                        theme,
                      ),
                      _buildList(
                        state.achievements
                            .where((a) => a.isInProgress)
                            .toList(),
                        theme,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Нет данных'));
        },
      ),
    );
  }

  Widget _buildProgressBanner(GroupAchievementsLoaded state, ThemeData theme) {
    final progress = state.totalCount > 0
        ? (state.earnedCount / state.totalCount * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${state.earnedCount}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              Text('Получено', style: theme.textTheme.bodySmall),
            ],
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 8,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${state.totalCount}',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text('Всего', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<GroupAchievement> achievements, ThemeData theme) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined,
                size: 64, color: theme.textTheme.bodySmall?.color),
            const SizedBox(height: 16),
            Text(
              'Нет достижений в этой категории',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.textTheme.bodySmall?.color),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  a.isEarned ? Colors.amber : theme.colorScheme.surfaceVariant,
              child: Icon(
                Icons.groups,
                color: a.isEarned ? Colors.white : Colors.grey,
              ),
            ),
            title: Text(
              a.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: a.isLocked ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.description),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: a.progressPercent / 100,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
                const SizedBox(height: 2),
                Text(
                  '${a.progress} / ${a.conditionValue}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            trailing: a.isEarned
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Text(
                    '+${a.rewardPoints}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            isThreeLine: true,
            onTap: () => _showDetails(a),
          ),
        );
      },
    );
  }

  void _showDetails(GroupAchievement a) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(a.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.description),
            const SizedBox(height: 16),
            Text('Тип: ${a.type.displayName}'),
            Text('Цель: ${a.conditionValue}'),
            if (a.rewardPoints > 0)
              Text('Награда: +${a.rewardPoints} баллов'),
            if (a.isEarned && a.earnedAt != null)
              Text(
                'Получено: ${a.earnedAt}',
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
