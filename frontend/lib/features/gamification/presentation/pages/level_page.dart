import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/level/level_bloc.dart';
import '../bloc/level/level_event.dart';
import '../bloc/level/level_state.dart';
import '../widgets/level_progress_bar.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    context.read<LevelBloc>().add(LoadLevel(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уровень'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LevelBloc>().add(RefreshLevel(widget.userId));
            },
          ),
        ],
      ),
      body: BlocBuilder<LevelBloc, LevelState>(
        builder: (context, state) {
          if (state is LevelLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LevelError) {
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
                    onPressed: _loadLevel,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is LevelLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LevelBloc>().add(RefreshLevel(widget.userId));
              },
              child: _buildLevelContent(state.level, theme),
            );
          }

          return const Center(child: Text('Нет данных'));
        },
      ),
    );
  }

  Widget _buildLevelContent(level, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${level.level}',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'УРОВЕНЬ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${level.totalPoints} баллов',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Прогресс до следующего уровня',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LevelProgressBar(
                  currentLevel: level.level,
                  progress: level.progressPercent,
                  currentPoints: level.totalPoints,
                  pointsToNext: level.pointsToNextLevel,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Card(
          color: theme.primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivationalMessage(level.level),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getMotivationalMessage(int level) {
    if (level == 0) {
      return 'Начните выполнять привычки, чтобы повысить уровень!';
    } else if (level < 5) {
      return 'Отличное начало! Продолжайте в том же духе!';
    } else if (level < 10) {
      return 'Вы делаете большие успехи! Так держать!';
    } else {
      return 'Невероятно! Вы настоящий мастер привычек!';
    }
  }
}
