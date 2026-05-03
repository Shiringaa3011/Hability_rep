import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/group_entity.dart';
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import 'create_group_page.dart';
import 'group_detail_page.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupsBloc(
        getUserGroups: di.sl(),
        currentUserId: userId,
      )..add(LoadUserGroups(userId)),
      child: _GroupsScaffold(userId: userId),
    );
  }
}

class _GroupsScaffold extends StatelessWidget {
  const _GroupsScaffold({required this.userId});

  final String userId;

  Future<void> _onCreate(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => CreateGroupPage(userId: userId)),
    );
    if (!context.mounted) return;
    if (ok == true) {
      context.read<GroupsBloc>().add(RefreshGroups(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreate(context),
        child: const Icon(DSIcons.add),
      ),
      body: BlocBuilder<GroupsBloc, GroupsState>(
        builder: (context, state) {
          if (state.isLoading && state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.groups.isEmpty) {
            return Center(
              child: Text(
                'Ошибка: ${state.error}',
                style: AppTextStyles.bodyMedium.copyWith(color: colors.destructive),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<GroupsBloc>().add(RefreshGroups(userId)),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.bottomNavReserve,
              ),
              children: [
                Text(
                  'Группы',
                  style: AppTextStyles.displayMedium
                      .copyWith(color: colors.foreground),
                ),
                const SizedBox(height: 4),
                Text(
                  state.groups.isEmpty
                      ? 'Нет групп — создайте первую'
                      : '${state.groups.length} ${_pluralize(state.groups.length)}',
                  style: AppTextStyles.bodySmall.copyWith(color: colors.mutedForeground),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (state.groups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Column(
                      children: [
                        Icon(DSIcons.groups, size: 48, color: colors.mutedForeground),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Пока вы не состоите в группах',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  )
                else
                  ...state.groups.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _GroupTile(group: g, userId: userId),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _pluralize(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'групп';
    if (mod10 == 1) return 'группа';
    if (mod10 >= 2 && mod10 <= 4) return 'группы';
    return 'групп';
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.userId});

  final GroupEntity group;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DSCard(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => GroupDetailPage(
              groupId: group.id,
              currentUserId: userId,
            ),
          ),
        );
      },
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(DSIcons.groups, color: colors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.titleSmall.copyWith(color: colors.foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (group.description != null && group.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    group.description!,
                    style: AppTextStyles.caption.copyWith(color: colors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Icon(DSIcons.chevronRight, color: colors.mutedForeground, size: 20),
        ],
      ),
    );
  }
}
