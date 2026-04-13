import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../injection_container.dart' as di;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final dio = di.sl<Dio>();
      final response = await dio.post(
        '/users/register',
        data: {
          'email': _email.text.trim(),
          'password': _password.text,
        },
      );
      if (!mounted) return;
      final data = response.data as Map<String, dynamic>;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Успешно зарегистрирован: ${data['email']}',
          ),
        ),
      );
      Navigator.of(context).pop(data);
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail']?.toString() ?? 'Ошибка регистрации')
          : 'Ошибка регистрации';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Введите email';
                if (!value.contains('@')) return 'Неверный формат email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if ((v ?? '').length < 6) return 'Минимум 6 символов';
                return null;
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Зарегистрироваться'),
            ),
            const SizedBox(height: 8),
            Text(
              'TODO: добавить шаг с email-кодом и имя пользователя по полному ТЗ.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
