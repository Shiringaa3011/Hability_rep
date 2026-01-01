import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/achievements/achievements_bloc.dart';
import '../bloc/achievements/achievements_event.dart';
import '../bloc/achievements/achievements_state.dart';
import '../widgets/achievement_card.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAchievements() {
    context.read<AchievementsBloc>().add(
          LoadAchievements(widget.userId),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AchievementsBloc>().add(
                    RefreshAchievements(widget.userId),
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
      body: BlocBuilder<AchievementsBloc, AchievementsState>(
        builder: (context, state) {
          if (state is AchievementsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AchievementsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAchievements,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is AchievementsLoaded) {
            return Column(
              children: [
                _buildProgressBanner(state, theme),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAchievementsList(state.achievements, theme),
                      _buildAchievementsList(
                        state.achievements.where((a) => a.isEarned).toList(),
                        theme,
                      ),
                      _buildAchievementsList(
                        state.achievements.where((a) => a.isInProgress).toList(),
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

  Widget _buildProgressBanner(AchievementsLoaded state, ThemeData theme) {
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
              Text(
                'Получено',
                style: theme.textTheme.bodySmall,
              ),
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${state.totalCount}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Всего',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List achievements, ThemeData theme) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет достижений в этой категории',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AchievementCard(
            achievement: achievements[index],
            onTap: () {
              _showAchievementDetails(achievements[index]);
            },
          ),
        );
      },
    );
  }

  void _showAchievementDetails(achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            Text('Тип: ${achievement.type.displayName}'),
            Text('Цель: ${achievement.conditionValue}'),
            if (achievement.rewardPoints > 0)
              Text('Награда: +${achievement.rewardPoints} баллов'),
            if (achievement.isEarned && achievement.earnedAt != null)
              Text(
                'Получено: ${achievement.earnedAt}',
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
