import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_level.dart';
import '../bloc/achievements/achievements_bloc.dart';
import '../bloc/achievements/achievements_event.dart';
import '../bloc/achievements/achievements_state.dart';
import '../bloc/level/level_bloc.dart';
import '../bloc/level/level_event.dart';
import '../bloc/level/level_state.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<LevelBloc>()..add(LoadLevel(userId))),
        BlocProvider(
          create: (_) => di.sl<AchievementsBloc>()..add(LoadAchievements(userId)),
        ),
      ],
      child: const _AchievementsScaffold(),
    );
  }
}

class _AchievementsScaffold extends StatelessWidget {
  const _AchievementsScaffold();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.bottomNavReserve,
        ),
        children: const [
          _Title(),
          SizedBox(height: AppSpacing.xl),
          _LevelBlock(),
          SizedBox(height: AppSpacing.xl),
          _EarnedSection(),
          SizedBox(height: AppSpacing.xl),
          _AllAchievementsSection(),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text(
      'Достижения',
      style: AppTextStyles.displayMedium.copyWith(color: colors.foreground),
    );
  }
}

class _LevelBlock extends StatelessWidget {
  const _LevelBlock();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LevelBloc, LevelState>(
      builder: (context, state) {
        if (state is LevelLoaded) return _LevelView(level: state.level);
        if (state is LevelError) {
          return Text(
            state.message,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appColors.destructive,
            ),
          );
        }
        return const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _LevelView extends StatelessWidget {
  const _LevelView({required this.level});

  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'УРОВЕНЬ',
                  style: AppTextStyles.overline.copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: 4),
                Text(
                  '${level.level}',
                  style: AppTextStyles.displayLarge.copyWith(color: colors.foreground),
                ),
              ],
            ),
            Text(
              '${level.totalPoints} очков',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DSProgressBar(value: level.progressPercent / 100, height: 6),
        const SizedBox(height: 4),
        Text(
          'До следующего: ${level.pointsToNextLevel} очков',
          style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
        ),
      ],
    );
  }
}

class _EarnedSection extends StatelessWidget {
  const _EarnedSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsBloc, AchievementsState>(
      builder: (context, state) {
        if (state is! AchievementsLoaded) return const SizedBox.shrink();
        final earned = state.achievements.where((a) => a.isEarned).toList();
        if (earned.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DSSectionHeader(label: 'Получено (${earned.length})'),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: earned
                  .map((a) => DSChip(label: a.name, icon: _iconFor(a)))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _AllAchievementsSection extends StatelessWidget {
  const _AllAchievementsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AchievementsBloc, AchievementsState>(
      builder: (context, state) {
        if (state is AchievementsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AchievementsError) {
          return Text(
            state.message,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appColors.destructive,
            ),
          );
        }
        if (state is! AchievementsLoaded) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DSSectionHeader(label: 'Все цели'),
            const SizedBox(height: AppSpacing.md),
            ...state.achievements.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _AchievementRow(achievement: a),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final earned = achievement.isEarned;
    final iconBg = earned ? colors.primary.withValues(alpha: 0.15) : colors.muted;
    final iconFg = earned ? colors.primary : colors.mutedForeground;

    return DSCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(achievement), size: 18, color: iconFg),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  achievement.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: earned ? colors.foreground : colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
                ),
                if (!earned && achievement.progressPercent > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DSProgressBar(value: achievement.progressPercent / 100, height: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconFor(Achievement a) {
  switch (a.type) {
    case AchievementType.streak:
      return DSIcons.flame;
    case AchievementType.totalHabits:
      return DSIcons.habits;
    case AchievementType.level:
      return DSIcons.crown;
    case AchievementType.points:
      return DSIcons.starFilled;
    case AchievementType.perfectWeek:
      return DSIcons.trophy;
  }
}
