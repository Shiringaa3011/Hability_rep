import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/group_stats.dart';
import '../../domain/entities/user_stats.dart';
import '../bloc/group_stats/group_stats_bloc.dart';
import '../bloc/group_stats/group_stats_event.dart';
import '../bloc/group_stats/group_stats_state.dart';
import '../../../../core/error/error_screen.dart';

class GroupStatsPage extends StatelessWidget {
  const GroupStatsPage({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<GroupStatsBloc>()
        ..add(LoadGroupStats(groupId: groupId, period: StatsPeriod.week)),
      child: _GroupStatsScaffold(groupId: groupId),
    );
  }
}

class _GroupStatsScaffold extends StatefulWidget {
  const _GroupStatsScaffold({required this.groupId});

  final String groupId;

  @override
  State<_GroupStatsScaffold> createState() => _GroupStatsScaffoldState();
}

class _GroupStatsScaffoldState extends State<_GroupStatsScaffold> {
  StatsPeriod _period = StatsPeriod.week;

  void _changePeriod(StatsPeriod p) {
    setState(() => _period = p);
    context.read<GroupStatsBloc>().add(
          ChangeGroupStatsPeriod(groupId: widget.groupId, period: p),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: const Text('Статистика группы')),
      body: BlocBuilder<GroupStatsBloc, GroupStatsState>(
        builder: (context, state) {
          if (state is GroupStatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupStatsError) {
            return AppErrorWidget(
              message: 'Не удалось загрузить статистику группы',
              onRetry: () => context.read<GroupStatsBloc>().add(
                    LoadGroupStats(groupId: widget.groupId, period: _period),
                  ),
            );
          }
          if (state is GroupStatsLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context.read<GroupStatsBloc>().add(
                    RefreshGroupStats(groupId: widget.groupId, period: _period),
                  ),
              child: _GroupStatsContent(
                stats: state.stats,
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

class _GroupStatsContent extends StatelessWidget {
  const _GroupStatsContent({
    required this.stats,
    required this.period,
    required this.onPeriodChanged,
  });

  final GroupStats stats;
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final avgPercent = stats.averageCompletionRate.round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.bottomNavReserve,
      ),
      children: [
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
              'СРЕДНИЙ ПРОЦЕНТ',
              style: AppTextStyles.overline.copyWith(color: colors.mutedForeground),
            ),
            Text(
              '$avgPercent%',
              style: AppTextStyles.displayMedium.copyWith(color: colors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DSProgressBar(value: stats.averageCompletionRate / 100),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: 'БАЛЛЫ ГРУППЫ',
                value: '${stats.totalPointsGroup}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _MiniStat(
                label: 'АКТИВНЫХ',
                value: '${stats.activeMembersCount}',
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
                label: 'УЧАСТНИКОВ',
                value: '${stats.members.length}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        DSSectionHeader(label: 'Рейтинг участников'),
        const SizedBox(height: AppSpacing.md),
        if (stats.members.isEmpty)
          _EmptyMembersCard()
        else
          ...stats.members.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _MemberCard(member: m),
            ),
          ),
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
  });

  final String label;
  final String value;

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
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(
              color: colors.foreground,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final GroupMemberStats member;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = member.completionRate.round();
    return DSCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: AppRadius.pillRadius,
            ),
            child: Center(
              child: Text(
                '${member.rank}',
                style: AppTextStyles.titleSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.username,
                  style: AppTextStyles.titleSmall.copyWith(color: colors.foreground),
                ),
                const SizedBox(height: 2),
                Text(
                  '$percent% • ${member.totalCompletions} выполнений',
                  style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${member.totalPoints}',
            style: AppTextStyles.titleSmall.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMembersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DSCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(
        'В группе пока нет участников',
        style: AppTextStyles.bodyMedium.copyWith(color: colors.mutedForeground),
        textAlign: TextAlign.center,
      ),
    );
  }
}
/*
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
*/