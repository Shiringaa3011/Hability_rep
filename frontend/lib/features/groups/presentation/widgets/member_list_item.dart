import 'package:flutter/material.dart';

import '../../domain/entities/group_member_entity.dart';

class MemberListItem extends StatelessWidget {
  final int rank;
  final GroupMemberEntity member;
  final bool isCurrentUser;
  final bool showLeaderBadge;
  final bool canRemove;
  final VoidCallback? onRemove;

  const MemberListItem({
    required this.rank,
    required this.member,
    required this.isCurrentUser,
    this.showLeaderBadge = false,
    this.canRemove = false,
    this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
        ),
      ),
      title: Row(
        children: [
          Text('#$rank'),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              member.username + (isCurrentUser ? ' (вы)' : ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showLeaderBadge)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.emoji_events_outlined,
                size: 18,
                color: theme.colorScheme.tertiary,
              ),
            ),
        ],
      ),
      subtitle: Text('${member.points} баллов'),
      trailing: canRemove && onRemove != null
          ? IconButton(
              icon: const Icon(Icons.person_remove_outlined),
              tooltip: 'Удалить из группы',
              onPressed: onRemove,
            )
          : (showLeaderBadge && member.reactions > 0)
              ? Chip(
                  // добавить значок реакции
                  label: Text('star ${member.reactions}'),
                  visualDensity: VisualDensity.compact,
                )
              : null,
    );
  }
}
