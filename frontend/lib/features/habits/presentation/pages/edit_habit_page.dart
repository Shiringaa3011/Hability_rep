import 'package:flutter/material.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../home/domain/entities/today_habit_entity.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../home/domain/usecases/get_home_group_filter_options.dart';
import '../../../home/domain/usecases/get_habit_by_id.dart';
import '../../../home/domain/usecases/upsert_habit_definition.dart';
import '../../../../injection_container.dart' as di;
import '../../../home/domain/usecases/delete_habit.dart';

class EditHabitPage extends StatefulWidget {
  final String userId;
  final String habitId;

  const EditHabitPage({
    required this.userId,
    required this.habitId,
    super.key,
  });

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  
  String _frequency = 'daily';
  int? _selectedWeekday;
  
  TimeOfDay? _time;
  String? _groupId;
  String? _groupName;
  List<HomeGroupFilterOption> _groups = const [];
  bool _reminders = false;
  TimeOfDay? _reminderTime;
  bool _loading = true;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final habit = await di.sl<GetHabitById>()(widget.habitId);
      final groups = await di.sl<GetHomeGroupFilterOptions>()(widget.userId);
      if (!mounted) return;
      
      if (habit == null) {
        setState(() {
          _loadError = true;
          _loading = false;
        });
        return;
      }
      
      _title.text = habit.title;
      _description.text = habit.description ?? '';

      _frequency = habit.frequencyLabel == 'Еженедельно' ? 'weekly' : 'daily';
      _selectedWeekday = habit.dayOfWeek;
      
      _time = _parseTime(habit.scheduledTimeLabel);
      _groupId = habit.groupId;
      _groupName = habit.groupName;
      _reminders = habit.remindersEnabled;
      _reminderTime = _parseTime(habit.reminderTimeLabel);
      setState(() {
        _groups = groups.where((g) => g.groupId != null).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = true;
        _loading = false;
      });
    }
  }

  TimeOfDay? _parseTime(String? s) {
    if (s == null || !s.contains(':')) return null;
    final p = s.split(':');
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
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
      id: widget.habitId,
      title: _title.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      scheduledTimeLabel: _fmt(_time),
      frequencyLabel: _frequency == 'daily' ? 'Ежедневно' : 'Еженедельно',
      groupId: _groupId,
      groupName: _groupName,
      remindersEnabled: _reminders,
      reminderTimeLabel: _reminders ? _fmt(_reminderTime) : null,
      dayOfWeek: _frequency == 'weekly' ? _selectedWeekday : null,
    );
    await di.sl<UpsertHabitDefinition>()(widget.userId, habit);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить привычку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await di.sl<DeleteHabitUseCase>()(widget.habitId, widget.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Привычка удалена')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Привычка')),
        body: const Center(child: Text('Привычка не найдена')),
      );
    }
    final canSave = _title.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Изменить привычку')),
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
            const Text('Периодичность', style: TextStyle(fontWeight: FontWeight.w500)),
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
              const Text('День недели', style: TextStyle(fontWeight: FontWeight.w500)),
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
              value: _groupId,
              decoration: InputDecoration(
                labelText: 'Группа',
                border: OutlineInputBorder(),
                helperText: 'Группу нельзя изменить после создания привычки',
                helperStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                fillColor: Colors.grey.shade100,
                filled: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Личная привычка'),
                ),
                ..._groups.map(
                  (g) => DropdownMenuItem<String?>(
                    value: g.groupId,
                    child: Text(g.title),
                  ),
                ),
              ],
              onChanged: null,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text('Напоминания', style: Theme.of(context).textTheme.titleMedium),
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
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _deleteHabit,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Удалить привычку'),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWeekdayButtons() {
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
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              shortName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }
}