import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/entities/notification_history_item.dart';
import '../bloc/notification_history_bloc.dart';
import '../bloc/notification_history_event.dart';
import '../bloc/notification_history_state.dart';

class NotificationHistoryPage extends StatelessWidget {
  final String userId;
  final bool wrapInScaffold;

  const NotificationHistoryPage({
    required this.userId,
    this.wrapInScaffold = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final body = BlocProvider(
      create: (_) => NotificationHistoryBloc(
        userId: userId,
        bootstrapPipeline: di.sl(),
        getHistory: di.sl(),
        markRead: di.sl(),
      )..add(NotificationHistoryLoad(userId)),
      child: const _NotificationHistoryBody(),
    );
    if (!wrapInScaffold) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('История уведомлений')),
      body: body,
    );
  }
}

class _NotificationHistoryBody extends StatelessWidget {
  const _NotificationHistoryBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationHistoryBloc, NotificationHistoryState>(
      builder: (context, state) {
        if (state.loading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null && state.items.isEmpty) {
          return Center(child: Text(state.error!));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Непрочитанных: ${state.unreadLast30Days}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final bloc = context.read<NotificationHistoryBloc>();
                  bloc.add(NotificationHistoryLoad(bloc.userId));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: state.items.length,
                  itemBuilder: (context, i) {
                    final n = state.items[i];
                    return _NotificationTile(item: n);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationHistoryItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd.MM.yyyy HH:mm');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: item.read
          ? null
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      child: ListTile(
        title: Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.body, maxLines: 4, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(
              fmt.format(item.receivedAt),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: item.read
            ? const Icon(Icons.done_all, size: 20)
            : IconButton(
                icon: const Icon(Icons.mark_email_read_outlined),
                tooltip: 'Пометить прочитанным',
                onPressed: () {
                  context.read<NotificationHistoryBloc>().add(
                        NotificationHistoryMarkRead(item.id),
                      );
                },
              ),
        onTap: !item.read
            ? () => context.read<NotificationHistoryBloc>().add(
                  NotificationHistoryMarkRead(item.id),
                )
            : null,
      ),
    );
  }
}
