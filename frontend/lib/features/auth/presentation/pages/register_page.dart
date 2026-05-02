import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/theme/app_colors.dart';
import '../../../../core/services/auth_storage.dart';
import '../../../../injection_container.dart' as di;
import 'verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final dio = di.sl<Dio>();
      final username = _username.text.trim();

      final response = await dio.post(
        '/users/register',
        data: {
          'email': _email.text.trim(),
          'password': _password.text,
          if (username.isNotEmpty) 'username': username,
        },
      );
      if (!mounted) return;

      await dio.post('/auth/send-code', data: {'email': _email.text.trim()});

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerificationPage(
            email: _email.text.trim(),
            isRegistration: true,
          ),
        ),
      );
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
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Регистрация',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Создайте аккаунт для отслеживания привычек',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.mutedForeground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _username,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Никнейм',
                      hintText: 'Необязательно',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty && v.trim().length < 3) {
                        return 'Минимум 3 символа';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Введите email';
                      if (!value.contains('@')) return 'Неверный формат email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Пароль *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if ((v ?? '').length < 6) return 'Минимум 6 символов';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Зарегистрироваться'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Уже есть аккаунт? Войти'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '* — обязательные поля',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Никнейм можно не указывать — он сформируется из email.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}