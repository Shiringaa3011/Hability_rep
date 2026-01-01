import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_stats.dart';
import '../bloc/stats/stats_bloc.dart';
import '../bloc/stats/stats_event.dart';
import '../bloc/stats/stats_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/streak_indicator.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  StatsPeriod _selectedPeriod = StatsPeriod.week;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    context.read<StatsBloc>().add(
          LoadStats(userId: widget.userId, period: _selectedPeriod),
        );
  }

  void _onPeriodChanged(StatsPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    context.read<StatsBloc>().add(
          ChangePeriod(userId: widget.userId, period: period),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatsBloc>().add(
                    RefreshStats(userId: widget.userId, period: _selectedPeriod),
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(theme),
          Expanded(
            child: BlocBuilder<StatsBloc, StatsState>(
              builder: (context, state) {
                if (state is StatsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StatsError) {
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
                          onPressed: _loadStats,
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is StatsLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<StatsBloc>().add(
                            RefreshStats(
                              userId: widget.userId,
                              period: _selectedPeriod,
                            ),
                          );
                    },
                    child: _buildStatsContent(state, theme),
                  );
                }

                return const Center(child: Text('Нет данных'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: StatsPeriod.values.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(period.displayName),
                selected: isSelected,
                onSelected: (_) => _onPeriodChanged(period),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsContent(StatsLoaded state, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              title: 'Выполнено',
              value: '${state.stats.totalCompletions}',
              icon: Icons.check_circle,
            ),
            StatCard(
              title: 'Процент',
              value: '${state.stats.completionRate.toStringAsFixed(1)}%',
              icon: Icons.percent,
              color: _getCompletionRateColor(state.stats.completionRate),
            ),
            StatCard(
              title: 'Текущая серия',
              value: '${state.stats.currentStreak}',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            StatCard(
              title: 'Макс. серия',
              value: '${state.stats.maxStreak}',
              icon: Icons.emoji_events,
              color: Colors.amber,
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        StatCard(
          title: 'Баллы за период',
          value: '${state.stats.totalPointsEarned}',
          icon: Icons.stars,
          color: Colors.purple,
        ),
        const SizedBox(height: 24),

        if (state.habitsStats.isNotEmpty) ...[
          Text(
            'Статистика по привычкам',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...state.habitsStats.map(
            (habitStats) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: StreakIndicator(streak: habitStats.currentStreak),
                title: Text(habitStats.habitName),
                subtitle: Text(
                  'Выполнено: ${habitStats.totalCompletions} раз\n'
                  'Процент: ${habitStats.completionRate.toStringAsFixed(1)}%',
                ),
                trailing: Text(
                  '+${habitStats.totalPointsEarned}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }
}
