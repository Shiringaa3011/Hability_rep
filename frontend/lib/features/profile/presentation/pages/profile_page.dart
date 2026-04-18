import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/services/auth_storage.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../injection_container.dart' as di;
import '../../../gamification/domain/entities/user_level.dart';
import '../../../gamification/presentation/bloc/level/level_bloc.dart';
import '../../../gamification/presentation/bloc/level/level_event.dart';
import '../../../gamification/presentation/bloc/level/level_state.dart';
import '../../../gamification/presentation/pages/level_page.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../../notifications/presentation/pages/notification_history_page.dart';
import '../../../notifications/presentation/pages/notification_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.userId,
    this.initialTab = 0,
    super.key,
  });

  final String userId;
  final int initialTab;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _username;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authStorage = di.sl<AuthStorage>();
    final username = await authStorage.getUsername();
    final email = await authStorage.getEmail();

    setState(() {
      _username = username;
      _email = email;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<LevelBloc>()..add(LoadLevel(widget.userId)),
      child: _ProfileScaffold(
        userId: widget.userId,
        username: _username ?? 'Пользователь',
        email: _email ?? '',
      ),
    );
  }
}

class _ProfileScaffold extends StatelessWidget {
  const _ProfileScaffold({
    required this.userId,
    required this.username,
    required this.email,
  });

  final String userId;
  final String username;
  final String email;

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
          _IdentityCard(
            userId: userId,
            username: username,
            email: email,
          ),
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
          const SizedBox(height: AppSpacing.sm),
          ListenableBuilder(
            listenable: ThemeModeController.instance,
            builder: (context, _) => _MenuItem(
              icon: _themeIcon(ThemeModeController.instance.value),
              label: 'Оформление',
              value: ThemeModeController.instance.displayLabel,
              onTap: () => _showThemeSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return DSIcons.lightMode;
      case ThemeMode.dark:
        return DSIcons.darkMode;
      case ThemeMode.system:
        return DSIcons.systemMode;
    }
  }

  static Future<void> _showThemeSheet(BuildContext context) async {
    final colors = context.appColors;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Оформление',
                  style: AppTextStyles.titleMedium.copyWith(color: colors.foreground),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ThemeOption(
                  mode: ThemeMode.system,
                  icon: DSIcons.systemMode,
                  label: 'Системная',
                ),
                const SizedBox(height: AppSpacing.sm),
                _ThemeOption(
                  mode: ThemeMode.light,
                  icon: DSIcons.lightMode,
                  label: 'Светлая',
                ),
                const SizedBox(height: AppSpacing.sm),
                _ThemeOption(
                  mode: ThemeMode.dark,
                  icon: DSIcons.darkMode,
                  label: 'Тёмная',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.label,
  });

  final ThemeMode mode;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final selected = ThemeModeController.instance.value == mode;
    return DSCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderColor: selected ? colors.primary : null,
      onTap: () async {
        await ThemeModeController.instance.set(mode);
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: selected ? colors.primary : colors.mutedForeground,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? colors.primary : colors.foreground,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (selected) Icon(DSIcons.check, size: 20, color: colors.primary),
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
  const _IdentityCard({
    required this.userId,
    required this.username,
    required this.email,
  });

  final String userId;
  final String username;
  final String email;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '?';
    
    return DSCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      onTap: () {
        final levelBloc = context.read<LevelBloc>();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: levelBloc,
              child: LevelPage(userId: userId),
            ),
          ),
        );
      },
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
                  firstLetter,
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
                      username,
                      style: AppTextStyles.titleMedium.copyWith(color: colors.foreground),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
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
              if (state is LevelLoaded) return _LevelRow(level: state.level, userId: userId);
              return const _LevelPlaceholder();
            },
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level, required this.userId});

  final UserLevel level;
  final String userId;

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
        const SizedBox(height: 16),
        Text(
          'Приглашения в группы',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _PendingInvitesSection(userId: userId),
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

class _PendingInvitesSection extends StatelessWidget {
  final String userId;

  const _PendingInvitesSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    // TODO: реализовать список приглашений
    return const SizedBox.shrink();
  }
}