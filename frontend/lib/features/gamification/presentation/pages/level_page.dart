import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/user_level.dart';
import '../bloc/level/level_bloc.dart';
import '../bloc/level/level_event.dart';
import '../bloc/level/level_state.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({required this.userId, super.key});

  final String userId;

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  @override
  void initState() {
    super.initState();
    context.read<LevelBloc>().add(LoadLevel(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const DSAppBar(title: 'Уровень', showBack: true),
      body: BlocBuilder<LevelBloc, LevelState>(
        builder: (context, state) {
          if (state is LevelLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LevelError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colors.destructive),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DSButton(
                      label: 'Повторить',
                      onPressed: () => context
                          .read<LevelBloc>()
                          .add(LoadLevel(widget.userId)),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is LevelLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<LevelBloc>()
                  .add(RefreshLevel(widget.userId)),
              child: _Content(level: state.level),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.level});

  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      children: [
        Center(
          child: Container(
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: AppShadows.elevated,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${level.level}',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: colors.primaryForeground,
                    fontSize: 56,
                  ),
                ),
                Text(
                  'УРОВЕНЬ',
                  style: AppTextStyles.overline.copyWith(
                    color: colors.primaryForeground.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Text(
            '${level.totalPoints} баллов',
            style: AppTextStyles.titleLarge.copyWith(color: colors.foreground),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        DSCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Прогресс до следующего уровня',
                style: AppTextStyles.titleSmall.copyWith(color: colors.foreground),
              ),
              const SizedBox(height: AppSpacing.md),
              DSProgressBar(value: level.progressPercent / 100),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${level.totalPoints} оч',
                    style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
                  ),
                  Text(
                    '${level.pointsToNextLevel} до уровня ${level.level + 1}',
                    style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        DSCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(DSIcons.trophy, size: 28, color: colors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _motivation(level.level),
                  style: AppTextStyles.bodyMedium.copyWith(color: colors.foreground),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _motivation(int level) {
    if (level == 0) return 'Начните выполнять привычки, чтобы повысить уровень!';
    if (level < 5) return 'Отличное начало! Продолжайте в том же духе!';
    if (level < 10) return 'Вы делаете большие успехи! Так держать!';
    return 'Невероятно! Вы настоящий мастер привычек!';
  }
}
