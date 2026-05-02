import 'package:dio/dio.dart';
import '../services/logger_service.dart';

class AppException implements Exception {
  const AppException(this.message);
  
  final String message;
  
  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error']) : super(message);
}

class CacheException extends AppException {
  const CacheException([String message = 'Cache error']) : super(message);
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error']) : super(message);
}

AppException fromDioException(DioException e) {
  AppLogger.error(
    'Network request failed: ${e.requestOptions.uri}',
    '${e.type}: ${e.message}',
  );

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException('Нет подключения к интернету');
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        return const ServerException('Данные не найдены');
      } else if (statusCode == 500) {
        return const ServerException('Ошибка сервера');
      }
      return const ServerException('Ошибка сервера');
    default:
      return const NetworkException('Что-то пошло не так');
  }
}
