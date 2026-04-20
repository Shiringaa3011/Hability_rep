import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../bloc/groups_bloc.dart';
import '../bloc/groups_event.dart';
import '../bloc/groups_state.dart';
import '../widgets/group_card.dart';
import 'create_group_page.dart';
import 'group_detail_page.dart';

class GroupsPage extends StatelessWidget {
  final String userId;

  const GroupsPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupsBloc(
        getUserGroups: di.sl(),
        currentUserId: userId,
      )..add(LoadUserGroups(userId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Мои группы')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final ok = await Navigator.of(context).push<bool>(
              MaterialPageRoute<bool>(
                builder: (_) => CreateGroupPage(userId: userId),
              ),
            );
            if (!context.mounted) return;
            if (ok == true) {
              context.read<GroupsBloc>().add(RefreshGroups(userId));
            }
          },
          icon: const Icon(Icons.group_add),
          label: const Text('Группа'),
        ),
        body: BlocBuilder<GroupsBloc, GroupsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text('Ошибка: ${state.error}'));
            }
            if (state.groups.isEmpty) {
              return const Center(child: Text('Вы пока не состоите в группах'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<GroupsBloc>().add(RefreshGroups(userId));
              },
              child: ListView.builder(
                itemCount: state.groups.length,
                itemBuilder: (context, index) {
                  final group = state.groups[index];
                  return GroupCard(
                    group: group,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupDetailPage(
                            groupId: group.id,
                            currentUserId: userId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}