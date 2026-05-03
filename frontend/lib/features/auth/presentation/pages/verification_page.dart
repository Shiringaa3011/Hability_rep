import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/theme/app_colors.dart';
import '../../../../core/services/auth_storage.dart';
import '../../../../injection_container.dart' as di;

class VerificationPage extends StatefulWidget {
  final String email;
  final bool isRegistration;

  const VerificationPage({
    required this.email,
    required this.isRegistration,
    super.key,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите код полностью')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final dio = di.sl<Dio>();
      final response = await dio.post('/auth/verify-code', data: {
        'email': widget.email,
        'code': code,
      });

      if (!mounted) return;

      final data = response.data as Map<String, dynamic>;
      final authStorage = di.sl<AuthStorage>();
      await authStorage.saveUser(
        userId: data['user_id'] as String,
        username: data['username'] as String? ?? widget.email.split('@').first,
        email: data['email'] as String,
      );

      // Сохранить FCM-токен
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await dio.post('/notifications/fcm-token', data: {
            'user_id': data['user_id'],
            'fcm_token': token,
          });
        }
      } catch (_) {}

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: data['user_id'] as String,
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail']?.toString() ?? 'Неверный код')
          : 'Неверный код';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(detail)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    try {
      final dio = di.sl<Dio>();
      await dio.post('/auth/send-code', data: {'email': widget.email});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Код отправлен повторно')),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Подтверждение',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Мы отправили код на ${widget.email}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.mutedForeground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) => Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      buildCounter: (context, {required int currentLength, required bool isFocused, required int? maxLength}) => null,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.foreground,
                        fontSize: 22,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: colors.input,
                      ),
                      onChanged: (v) => _onChanged(v, index),
                    ),
                  )),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _verify,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Подтвердить'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resendCode,
                  child: Text('Отправить код повторно', style: TextStyle(color: colors.mutedForeground)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}