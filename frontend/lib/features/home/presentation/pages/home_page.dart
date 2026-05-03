import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../injection_container.dart' as di;
import '../../../habits/presentation/pages/create_habit_page.dart';
import '../../../habits/presentation/pages/edit_habit_page.dart';
import '../../domain/entities/today_habit_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/error/error_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        userId: userId,
        getToday: di.sl(),
        getGroupOptions: di.sl(),
        toggle: di.sl(),
        completeHabit: di.sl(),
      )..add(HomeLoadRequested(userId)),
      child: _HabitsScaffold(userId: userId),
    );
  }
}

class _HabitsScaffold extends StatelessWidget {
  const _HabitsScaffold({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton(
        heroTag: 'habits_fab',
        onPressed: () => _onAddPressed(context),
        child: const Icon(DSIcons.add),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading && state.habits.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.habits.isEmpty) {
            return AppErrorWidget(
              message: state.error,
              onRetry: () => context.read<HomeBloc>().add(HomeLoadRequested(userId)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(HomeLoadRequested(userId));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl + 64,
              ),
              children: [
                _Header(day: state.selectedDay),
                const SizedBox(height: AppSpacing.lg),
                DSDateStrip(
                  selected: state.selectedDay,
                  onSelect: (d) =>
                      context.read<HomeBloc>().add(HomeDateSelected(d)),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (state.groupOptions.isNotEmpty) ...[
                  _GroupChips(state: state),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _ProgressSummary(habits: state.habits),
                const SizedBox(height: AppSpacing.xl),
                if (state.habits.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      'Нет привычек на этот день',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colors.mutedForeground),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...state.habits.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _HabitTile(habit: h, userId: userId, selectedDay: state.selectedDay,),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onAddPressed(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateHabitPage(userId: userId),
      ),
    );
    if (!context.mounted) return;
    if (created == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<HomeBloc>().add(HomeLoadRequested(userId));
        }
      });
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getMonthName(day).toUpperCase(),
          style: AppTextStyles.overline.copyWith(color: colors.mutedForeground),
        ),
        /*const SizedBox(height: 4),
        Text(
          '${_HabitsScaffold.weekdayLabel(day)}, ${day.day}',
          style: AppTextStyles.bodySmall.copyWith(color: colors.mutedForeground),
        ),*/
      ],
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.habits});

  final List<TodayHabitEntity> habits;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final total = habits.length;
    if (total == 0) return const SizedBox.shrink();

    final completed = habits.where((h) => h.completedToday).length;
    final percent = (completed / total * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed из $total',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$percent%',
              style: AppTextStyles.bodySmall.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DSProgressBar(value: completed / total),
      ],
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.userId,
    required this.selectedDay,
  });

  final TodayHabitEntity habit;
  final String userId;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final muted = colors.mutedForeground;
    final fg = colors.foreground;
    final isFutureDay = selectedDay.isAfter(DateTime.now());

    return Opacity(
      opacity: isFutureDay ? 0.65 : 1.0,
      child: DSCard(
        highlighted: habit.completedToday,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        onTap: isFutureDay ? null : () => _onEdit(context),
        child: Row(
          children: [
            DSCheckCircle(
              checked: habit.completedToday,
              onTap: isFutureDay
                  ? () {}
                  : () {
                      context.read<HomeBloc>().add(
                            HomeHabitToggled(
                              habitId: habit.id,
                              completed: !habit.completedToday,
                            ),
                          );
                    },
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: habit.completedToday ? muted : fg,
                      decoration: habit.completedToday ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_subtitle(habit) != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _subtitle(habit)!,
                      style: AppTextStyles.caption.copyWith(color: muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onEdit(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditHabitPage(userId: userId, habitId: habit.id),
      ),
    );
    if (!context.mounted) return;
    if (changed == true) {
      context.read<HomeBloc>().add(HomeLoadRequested(userId));
    }
  }

  static String? _subtitle(TodayHabitEntity h) {
    if (h.description != null && h.description!.isNotEmpty) return h.description;
    final parts = <String>[
      if (h.scheduledTimeLabel != null) h.scheduledTimeLabel!,
      if (h.frequencyLabel != null) h.frequencyLabel!,
      if (h.groupName != null) h.groupName!,
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }
}

class _GroupChips extends StatelessWidget {
  const _GroupChips({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final all = <HomeGroupFilterOption>[
      const HomeGroupFilterOption(groupId: null, title: 'Все'),
      ...state.groupOptions.where((o) => o.groupId != null),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final opt in all)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: DSChip(
                label: opt.title,
                selected: opt.groupId == state.selectedGroupId,
                onTap: () => context
                    .read<HomeBloc>()
                    .add(HomeGroupFilterSelected(opt.groupId)),
              ),
            ),
        ],
      ),
    );
  }
}
