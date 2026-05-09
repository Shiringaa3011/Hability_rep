import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/habit_stats.dart';
import '../../domain/entities/user_stats.dart';
import '../bloc/stats/stats_bloc.dart';
import '../bloc/stats/stats_event.dart';
import '../bloc/stats/stats_state.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return _StatsScaffold(userId: userId);
  }
}

class _StatsScaffold extends StatefulWidget {
  const _StatsScaffold({required this.userId});

  final String userId;

  @override
  State<_StatsScaffold> createState() => _StatsScaffoldState();
}

class _StatsScaffoldState extends State<_StatsScaffold> {
  StatsPeriod _period = StatsPeriod.week;

  void _changePeriod(StatsPeriod p) {
    setState(() => _period = p);
    context.read<StatsBloc>().add(ChangePeriod(userId: widget.userId, period: p));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StatsError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<StatsBloc>()
                  .add(LoadStats(userId: widget.userId, period: _period)),
            );
          }
          if (state is StatsLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<StatsBloc>().add(
                    RefreshStats(userId: widget.userId, period: _period),
                  ),
              child: _StatsContent(
                state: state,
                period: _period,
                onPeriodChanged: _changePeriod,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({
    required this.state,
    required this.period,
    required this.onPeriodChanged,
  });

  final StatsLoaded state;
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stats = state.stats;
    final percent = stats.completionRate.round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.bottomNavReserve,
      ),
      children: [
        Text('Статистика', style: AppTextStyles.displayMedium.copyWith(color: colors.foreground)),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            for (final p in StatsPeriod.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _PeriodPill(
                    label: p.displayName,
                    selected: p == period,
                    onTap: () => onPeriodChanged(p),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ВЫПОЛНЕНИЕ',
              style: AppTextStyles.overline.copyWith(color: colors.mutedForeground),
            ),
            Text(
              '$percent%',
              style: AppTextStyles.displayMedium.copyWith(color: colors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DSProgressBar(value: stats.completionRate / 100),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'СЕРИЯ',
                value: '${stats.currentStreak}',
                icon: DSIcons.flame,
                iconColor: colors.streak,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MiniStat(
                label: 'МАКСИМУМ',
                value: '${stats.maxStreak}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'ВЫПОЛНЕНО',
                value: '${stats.totalCompletions}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MiniStat(
                label: 'БАЛЛЫ',
                value: '${stats.totalPointsEarned}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'ПРОПУСКИ',
                value: '${stats.missedCount}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
        if (state.habitsStats.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          DSSectionHeader(label: 'По каждой привычке'),
          const SizedBox(height: AppSpacing.md),
          ...state.habitsStats.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _HabitStatCard(habit: h),
            ),
          ),
        ],
      ],
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.card,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            border: selected ? null : Border.all(color: colors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? colors.primaryForeground : colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DSCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.overline.copyWith(color: colors.mutedForeground),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? colors.foreground),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: AppTextStyles.displayMedium.copyWith(
                  color: colors.foreground,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  const _HabitStatCard({required this.habit});

  final HabitStats habit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = habit.completionRate.round();
    return DSCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  habit.habitName,
                  style: AppTextStyles.titleSmall.copyWith(color: colors.foreground),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  '$percent%',
                  style: AppTextStyles.caption.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DSProgressBar(value: habit.completionRate / 100, height: 6),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              DSStreakBadge(days: habit.currentStreak),
              const Spacer(),
              Text(
                'Пропуски: ${habit.missedCount}',
                style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.destructive),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            DSButton(label: 'Повторить', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
