class AppException implements Exception {
  const AppException(this.message);
  
  final String message;
  
  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error']) : super(message);
}

k
class CacheException extends AppException {
  const CacheException([String message = 'Cache error']) : super(message);
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network error']) : super(message);
}
