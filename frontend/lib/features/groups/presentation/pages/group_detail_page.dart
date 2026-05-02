import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/repositories/group_repository.dart';
import '../../domain/usecases/get_group_details.dart';
import '../../domain/usecases/leave_group.dart';
import '../../domain/usecases/remove_member.dart';
import '../../domain/usecases/send_reaction.dart';
import '../bloc/group_detail_bloc.dart';
import '../bloc/group_detail_event.dart';
import '../bloc/group_detail_state.dart';
import '../widgets/member_list_item.dart';
import '../widgets/reaction_button.dart';
import '../../../../core/design_system/theme/app_colors.dart';
import '../../../../core/design_system/theme/app_text_styles.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupId;
  final String currentUserId;

  const GroupDetailPage({
    required this.groupId,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupDetailBloc(
        groupId: groupId,
        currentUserId: currentUserId,
        getGroupDetails: di.sl<GetGroupDetails>(),
        leaveGroup: di.sl<LeaveGroup>(),
        removeMember: di.sl<RemoveMember>(),
        sendReaction: di.sl<SendReaction>(),
      )..add(LoadGroupDetail(groupId: groupId, currentUserId: currentUserId)),
      child: const _GroupDetailView(),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupDetailBloc, GroupDetailState>(
      listenWhen: (p, c) =>
          c.successMessage != p.successMessage ||
          c.error != p.error,
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          if (state.successMessage!.contains('вышли')) {
            Navigator.of(context).pop();
          }
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        final detail = state.detail;
        final colors = context.appColors;
        return Scaffold(
          appBar: AppBar(
            title: Text(detail?.group.name ?? 'Группа'),
          ),
          body: state.isLoading && detail == null
              ? const Center(child: CircularProgressIndicator())
              : detail == null
                  ? Center(child: Text(state.error ?? 'Нет данных'))
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<GroupDetailBloc>().add(
                              LoadGroupDetail(
                                groupId: state.groupId,
                                currentUserId: state.currentUserId,
                              ),
                            );
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (detail.group.description != null &&
                              detail.group.description!.isNotEmpty)
                            Text(
                              detail.group.description!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          const SizedBox(height: 16),
                          _SummaryCard(detail: detail),
                          const SizedBox(height: 16),
                          Text(
                            'Награды группы',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (detail.groupAchievements.isEmpty)
                            Text(
                              'Пока нет наград',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: detail.groupAchievements
                                  .map(
                                    (a) => Chip(
                                      avatar: const Icon(Icons.military_tech, size: 18),
                                      label: Text(a),
                                    ),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            'Рейтинг',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ...detail.members.asMap().entries.map((e) {
                            final rank = e.key + 1;
                            final m = e.value;
                            final isLeader = rank == 1;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: MemberListItem(
                                rank: rank,
                                member: m,
                                isCurrentUser: m.userId == state.currentUserId,
                                showLeaderBadge: isLeader,
                                canRemove: state.isOwner &&
                                    m.userId != state.currentUserId,
                                onRemove: () {
                                  context.read<GroupDetailBloc>().add(
                                        RemoveMemberPressed(m.id),
                                      );
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          if (state.isOwner) ...[
                            OutlinedButton.icon(
                              onPressed: () => _showInviteDialog(context, state),
                              icon: const Icon(Icons.person_add_alt_1),
                              label: const Text('Пригласить в группу'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => _showDeleteGroupDialog(context),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              label: const Text('Удалить группу', style: TextStyle(color: Colors.red)),
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(colors.card),
                                side: const WidgetStatePropertyAll(BorderSide(color: Colors.red)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (state.leader != null &&
                              state.leader!.userId != state.currentUserId)
                            ReactionToLeaderButton(
                              enabled: !state.isLoading,
                              reactionCount: state.leader!.reactions,
                              onPressed: () => context
                                  .read<GroupDetailBloc>()
                                  .add(SendReactionToLeader()),
                            ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: state.canLeave && !state.isLoading
                                ? () => _showLeaveDialog(context)
                                : null,
                            child: const Text('Выйти из группы'),
                          ),
                          if (!state.canLeave)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Создатель не может покинуть группу.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}

Future<void> _showDeleteGroupDialog(BuildContext context) async {
  final colors = context.appColors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Удалить группу?', style: TextStyle(color: colors.foreground)),
      content: Text('Это действие нельзя отменить. Все участники потеряют доступ к группе.', style: TextStyle(color: colors.mutedForeground)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Нет', style: TextStyle(color: colors.mutedForeground)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.destructive),
            foregroundColor: colors.destructive,
          ),
          child: const Text('Да'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    context.read<GroupDetailBloc>().add(DeleteGroupPressed());
  }
}

Future<void> _showInviteDialog(BuildContext context, GroupDetailState state) async {
  final repo = di.sl<GroupRepository>();
  
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => _InviteSheet(
      groupId: state.groupId,
      fromUserId: state.currentUserId,
      repository: repo,
    ),
  );
}

class _InviteSheet extends StatefulWidget {
  final String groupId;
  final String fromUserId;
  final GroupRepository repository;

  const _InviteSheet({
    required this.groupId,
    required this.fromUserId,
    required this.repository,
  });

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  Map<String, dynamic>? _selectedUser;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
bool _noResults = false;

Future<void> _search(String query) async {
  if (query.length < 2) {
    setState(() {
      _results = [];
      _noResults = false;
    });
    return;
  }
  try {
    final results = await widget.repository.searchUsers(query);
    setState(() {
      _results = results;
      _noResults = results.isEmpty;
    });
  } catch (_) {
    setState(() {
      _results = [];
      _noResults = true;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.mutedForeground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Пригласить участника',
              style: AppTextStyles.titleMedium?.copyWith(color: colors.foreground),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Введите имя пользователя',
                border: const OutlineInputBorder(),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _results = [];
                            _selectedUser = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() => _selectedUser = null);
                _search(v);
              },
            ),
          ),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._results.map((user) => ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.primary,
                child: Text(
                  user['username'][0].toUpperCase(),
                  style: TextStyle(color: colors.primaryForeground),
                ),
              ),
              title: Text(user['username']),
              selected: _selectedUser?['user_id'] == user['user_id'],
              onTap: () {
                setState(() => _selectedUser = user);
                _controller.text = user['username'];
              },
            )),
          ],
          if (_noResults && _controller.text.length >= 2)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      'Пользователь не найден',
      style: AppTextStyles.bodyMedium?.copyWith(color: colors.mutedForeground),
      textAlign: TextAlign.center,
    ),
  ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: FilledButton(
              onPressed: _selectedUser != null
                  ? () async {
                      try {
                        await widget.repository.inviteUser(
                          groupId: widget.groupId,
                          fromUserId: widget.fromUserId,
                          toUsername: _selectedUser!['username'],
                        );
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Приглашение отправлено')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка: $e')),
                          );
                        }
                      }
                    }
                  : null,
              child: const Text('Отправить приглашение'),
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> _showLeaveDialog(BuildContext context) async {
  final colors = context.appColors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Выйти из группы?', style: TextStyle(color: colors.foreground)),
      content: Text('Вы уверены, что хотите покинуть группу?', style: TextStyle(color: colors.mutedForeground)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Нет', style: TextStyle(color: colors.mutedForeground)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.destructive),
            foregroundColor: colors.destructive,
          ),
          child: const Text('Да'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    context.read<GroupDetailBloc>().add(LeaveGroupPressed());
  }
}

class _SummaryCard extends StatelessWidget {
  final GroupDetail detail;

  const _SummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final total = detail.totalGroupPoints;
    final leader = detail.members.isNotEmpty ? detail.members.first : null;
    final leaderRx = leader?.reactions ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общая статистика',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Сумма баллов группы: $total'),
            if (leader != null)
              Text(
                'Лидер: ${leader.username} · реакций: $leaderRx',
              ),
          ],
        ),
      ),
    );
  }
}
