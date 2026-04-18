import 'package:dio/dio.dart';
import '../services/auth_storage.dart';
import '../../injection_container.dart' as di;

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, handler) async {
    final authStorage = di.sl<AuthStorage>();
    final token = await authStorage.getToken();
    final userId = await authStorage.getUserId();
    
    // Добавляем ID пользователя в заголовок
    if (userId != null) {
      options.headers['X-User-Id'] = userId;
    }
    
    // Добавляем токен, если есть
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }
}