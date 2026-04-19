import 'package:flutter/material.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../injection_container.dart' as di;
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../../home/domain/entities/today_habit_entity.dart';
import '../../../home/domain/usecases/upsert_habit_definition.dart';

class CreateHabitPage extends StatefulWidget {
  final String userId;

  const CreateHabitPage({required this.userId, super.key});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  
  String _frequency = 'daily';
  int? _selectedWeekday;
  
  TimeOfDay? _time;
  String? _selectedGroupId;
  List<GroupEntity> _groups = [];
  bool _reminders = false;
  TimeOfDay? _reminderTime;
  bool _loading = true;

  late final GroupRepository _groupRepository;

  @override
  void initState() {
    super.initState();
    _groupRepository = di.sl<GroupRepository>();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final allGroups = await _groupRepository.getUserGroups(widget.userId);
      
      final sortedGroups = List<GroupEntity>.from(allGroups);
      sortedGroups.sort((a, b) {
        final aAvailable = a.habitsCount < 5;
        final bAvailable = b.habitsCount < 5;
        if (aAvailable && !bAvailable) return -1;
        if (!aAvailable && bAvailable) return 1;
        return 0;
      });
      
      setState(() {
        _groups = sortedGroups;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      print('Error loading groups: $e');
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickMainTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _time = t);
  }

  Future<void> _pickReminderTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _reminderTime = t);
  }

  String? _fmt(TimeOfDay? t) =>
      t == null ? null : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_frequency == 'weekly' && _selectedWeekday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите день недели')),
      );
      return;
    }
    
    final habit = TodayHabitEntity(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      scheduledTimeLabel: _fmt(_time),
      frequencyLabel: _frequency == 'daily' ? 'Ежедневно' : 'Еженедельно',
      groupId: _selectedGroupId,
      groupName: _selectedGroupId != null
          ? _groups.firstWhere(
              (g) => g.id == _selectedGroupId,
              orElse: () => GroupEntity(id: '', name: '', createdBy: '', createdAt: DateTime.now()),
            ).name
          : null,
      remindersEnabled: _reminders,
      reminderTimeLabel: _reminders ? _fmt(_reminderTime) : null,
      dayOfWeek: _frequency == 'weekly' ? _selectedWeekday : null,
    );
    
    await di.sl<UpsertHabitDefinition>()(widget.userId, habit);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final canSave = _title.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Новая привычка')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Название *',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Введите название' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Периодичность',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFrequencyButton(
                    label: 'Ежедневно',
                    isSelected: _frequency == 'daily',
                    onTap: () => setState(() => _frequency = 'daily'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFrequencyButton(
                    label: 'Еженедельно',
                    isSelected: _frequency == 'weekly',
                    onTap: () => setState(() => _frequency = 'weekly'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_frequency == 'weekly') ...[
              Text(
                'День недели',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildWeekdayButtons(),
              ),
              const SizedBox(height: 16),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Время выполнения'),
              subtitle: Text(_fmt(_time) ?? 'Не задано'),
              trailing: IconButton(
                icon: const Icon(Icons.schedule),
                onPressed: _pickMainTime,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              hint: const Text('Выберите группу'),
              decoration: const InputDecoration(
                labelText: 'Группа',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Личная привычка'),
                ),
                ..._groups.map((group) {
                  final isAvailable = group.habitsCount < 5;
                  return DropdownMenuItem<String?>(
                    value: group.id,
                    enabled: isAvailable,
                    child: Row(
                      children: [
                        Expanded(child: Text(group.name)),
                        if (!isAvailable)
                          Text(
                            'лимит 5 привычек',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGroupId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Напоминания',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.foreground,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Уведомления для этой привычки'),
              value: _reminders,
              onChanged: (v) => setState(() => _reminders = v),
            ),
            if (_reminders)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Время напоминания'),
                subtitle: Text(_fmt(_reminderTime) ?? 'Не выбрано'),
                trailing: IconButton(
                  icon: const Icon(Icons.alarm),
                  onPressed: _pickReminderTime,
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: canSave ? _save : null,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.muted,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colors.primaryForeground : colors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWeekdayButtons() {
    final colors = context.appColors;
    return List.generate(7, (index) {
      final weekdayValue = index + 1;
      final isSelected = _selectedWeekday == weekdayValue;
      final shortName = getWeekdayNameByValue(weekdayValue, short: true);
      
      return GestureDetector(
        onTap: () => setState(() => _selectedWeekday = weekdayValue),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : colors.muted,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              shortName,
              style: TextStyle(
                color: isSelected ? colors.primaryForeground : colors.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }
}