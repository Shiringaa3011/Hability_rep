import 'package:flutter/material.dart';

import '../../../../injection_container.dart' as di;
import '../../domain/usecases/create_group.dart';

class CreateGroupPage extends StatefulWidget {
  final String userId;

  const CreateGroupPage({required this.userId, super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await di.sl<CreateGroup>()(
      creatorUserId: widget.userId,
      name: _name.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final ok = _name.text.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Новая группа')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
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
            const SizedBox(height: 8),
            Text(
              'Приглашение участников: после подключения api.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: ok ? _submit : null,
              child: const Text('Создать группу'),
            ),
          ],
        ),
      ),
    );
  }
}
