import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../gamification/presentation/bloc/stats/stats_bloc.dart';
import '../../../gamification/presentation/pages/stats_page.dart';
import '../../../habits/presentation/pages/create_habit_page.dart';
import '../../../habits/presentation/pages/edit_habit_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../domain/entities/today_habit_entity.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(
        userId: userId,
        getToday: di.sl(),
        getGroupOptions: di.sl(),
        toggle: di.sl(),
      )..add(HomeLoadRequested(userId)),
      child: _HomeScaffold(userId: userId),
    );
  }
}

class _HomeScaffold extends StatelessWidget {
  final String userId;

  const _HomeScaffold({required this.userId});

  static const List<String> _monthsRu = [
    'январь',
    'февраль',
    'март',
    'апрель',
    'май',
    'июнь',
    'июль',
    'август',
    'сентябрь',
    'октябрь',
    'ноябрь',
    'декабрь',
  ];

  static String _monthYearRu(DateTime d) => '${_monthsRu[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои привычки'),
        actions: [
          IconButton(
            tooltip: 'Профиль',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfilePage(userId: userId),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Статистика привычек',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider(
                    create: (_) => di.sl<StatsBloc>(),
                    child: StatsPage(userId: userId),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => CreateHabitPage(userId: userId),
            ),
          );
          if (!context.mounted) return;
          if (created == true) {
            context.read<HomeBloc>().add(HomeLoadRequested(userId));
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Привычка'),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading && state.habits.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && state.habits.isEmpty) {
            return Center(child: Text(state.error!));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(HomeLoadRequested(userId));
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Text(
                  _HomeScaffold._monthYearRu(state.selectedDay),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                _DateStrip(
                  selected: state.selectedDay,
                  onSelect: (d) =>
                      context.read<HomeBloc>().add(HomeDateSelected(d)),
                ),
                const SizedBox(height: 12),
                _GroupDropdown(state: state),
                const SizedBox(height: 16),
                Text(
                  'На ${_formatDate(state.selectedDay)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (state.habits.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Нет привычек на этот день'),
                  )
                else
                  ...state.habits.map(
                    (h) => _HabitCard(habit: h, userId: userId),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _HabitCard extends StatelessWidget {
  final TodayHabitEntity habit;
  final String userId;

  const _HabitCard({required this.habit, required this.userId});

  @override
  Widget build(BuildContext context) {
    final dimmed = habit.completedToday;
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Checkbox(
            value: habit.completedToday,
            onChanged: (v) {
              if (v == null) return;
              context.read<HomeBloc>().add(
                    HomeHabitToggled(
                      habitId: habit.id,
                      completed: v,
                    ),
                  );
            },
          ),
          title: Text(habit.title),
          subtitle: habitSubtitleFor(habit),
          trailing: IconButton(
            tooltip: 'Изменить',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final changed = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) =>
                      EditHabitPage(userId: userId, habitId: habit.id),
                ),
              );
              if (!context.mounted) return;
              if (changed == true) {
                context.read<HomeBloc>().add(HomeLoadRequested(userId));
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget? habitSubtitleFor(TodayHabitEntity h) {
  final parts = <String>[
    if (h.scheduledTimeLabel != null) 'Время: ${h.scheduledTimeLabel}',
    if (h.frequencyLabel != null) h.frequencyLabel!,
    if (h.groupName != null) 'Группа: ${h.groupName}',
  ];
  if (parts.isEmpty) return null;
  return Text(parts.join(' · '));
}

class _GroupDropdown extends StatelessWidget {
  final HomeState state;

  const _GroupDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.groupOptions.isEmpty) return const SizedBox.shrink();
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Группа',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: state.selectedGroupId,
          items: state.groupOptions
              .map(
                (o) => DropdownMenuItem<String?>(
                  value: o.groupId,
                  child: Text(o.title),
                ),
              )
              .toList(),
          onChanged: (gid) {
            context.read<HomeBloc>().add(HomeGroupFilterSelected(gid));
          },
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _DateStrip({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final base = DateTime(selected.year, selected.month, selected.day);
    final start = base.subtract(const Duration(days: 3));
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, i) {
          final day = start.add(Duration(days: i));
          final isSel =
              day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelect(day),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                width: 56,
                decoration: BoxDecoration(
                  color: isSel
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayRu(day.weekday),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _weekdayRu(int w) {
    const names = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return names[(w - 1) % 7];
  }
}
