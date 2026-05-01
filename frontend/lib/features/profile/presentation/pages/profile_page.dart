import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../injection_container.dart' as di;
import '../../../gamification/domain/entities/user_level.dart';
import '../../../gamification/presentation/bloc/level/level_bloc.dart';
import '../../../gamification/presentation/bloc/level/level_event.dart';
import '../../../gamification/presentation/bloc/level/level_state.dart';
import '../../../notifications/presentation/pages/notification_history_page.dart';
import '../../../notifications/presentation/pages/notification_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    required this.userId,
    this.initialTab = 0,
    super.key,
  });

  final String userId;
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<LevelBloc>()..add(LoadLevel(userId)),
      child: _ProfileScaffold(userId: userId),
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold({required this.userId});

  final String userId;

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
        children: [
          _Header(),
          const SizedBox(height: AppSpacing.xl),
          const _IdentityCard(),
          const SizedBox(height: AppSpacing.xl),
          DSSectionHeader(label: 'Настройки'),
          const SizedBox(height: AppSpacing.md),
          _MenuItem(
            icon: DSIcons.notifications,
            label: 'Уведомления',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NotificationSettingsPage(userId: userId),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _MenuItem(
            icon: DSIcons.calendar,
            label: 'История уведомлений',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NotificationHistoryPage(userId: userId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Профиль',
          style: AppTextStyles.displayMedium.copyWith(color: colors.foreground),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.secondary,
            shape: BoxShape.circle,
          ),
          child: Icon(DSIcons.settings, size: 18, color: colors.mutedForeground),
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DSCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'А',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.primaryForeground,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Демо пользователь',
                      style: AppTextStyles.titleMedium.copyWith(color: colors.foreground),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Участник',
                      style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocBuilder<LevelBloc, LevelState>(
            builder: (context, state) {
              if (state is LevelLoaded) return _LevelRow(level: state.level);
              return const _LevelPlaceholder();
            },
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level});

  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(DSIcons.trophy, size: 16, color: colors.primary),
                const SizedBox(width: 6),
                Text(
                  'Уровень ${level.level}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '${level.totalPoints} оч',
              style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        DSProgressBar(value: level.progressPercent / 100),
        const SizedBox(height: 4),
        Text(
          '${level.pointsToNextLevel} оч до уровня ${level.level + 1}',
          style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
        ),
      ],
    );
  }
}

class _LevelPlaceholder extends StatelessWidget {
  const _LevelPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DSProgressBar(value: 0, height: 6),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DSCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: colors.mutedForeground),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: colors.foreground),
            ),
          ),
          if (value != null) ...[
            Text(
              value!,
              style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Icon(DSIcons.chevronRight, size: 20, color: colors.mutedForeground),
        ],
      ),
    );
  }
}
