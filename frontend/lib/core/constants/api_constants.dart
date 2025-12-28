class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8000';

  static const String apiV1 = '/api/v1';

  static String get apiBaseUrl => '$baseUrl$apiV1';

  static const String gamificationPath = '/gamification';
  static const String statsPath = '/stats';
  static const String achievementsPath = '/achievements';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const Duration statsCache = Duration(minutes: 5);
  static const Duration achievementsCache = Duration(hours: 1);
  static const Duration levelCache = Duration(minutes: 5);
}
