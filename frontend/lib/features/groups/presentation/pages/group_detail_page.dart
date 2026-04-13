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
                              'Пока нет наград (mock)',
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
                          ],
                          if (state.leader != null &&
                              state.leader!.userId != state.currentUserId)
                            ReactionToLeaderButton(
                              enabled: !state.isLoading,
                              onPressed: () => context
                                  .read<GroupDetailBloc>()
                                  .add(SendReactionToLeader()),
                            ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: state.canLeave && !state.isLoading
                                ? () => context
                                    .read<GroupDetailBloc>()
                                    .add(LeaveGroupPressed())
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

Future<void> _showInviteDialog(BuildContext context, GroupDetailState state) async {
  final c = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Пригласить пользователя'),
      content: TextField(
        controller: c,
        decoration: const InputDecoration(
          hintText: 'username',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () async {
            final username = c.text.trim();
            if (username.isEmpty) return;
            try {
              await di.sl<GroupRepository>().inviteUser(
                    groupId: state.groupId,
                    fromUserId: state.currentUserId,
                    toUsername: username,
                  );
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Приглашение отправлено')),
                );
              }
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка: $e')),
                );
              }
            }
          },
          child: const Text('Отправить'),
        ),
      ],
    ),
  );
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
