import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/notifications/domain/entities/notification_settings_snapshot.dart';
import 'package:habitly/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:habitly/features/notifications/domain/usecases/get_notification_settings.dart';

import 'get_notification_settings_test.mocks.dart';

@GenerateMocks([NotificationsRepository])
void main() {
  late GetNotificationSettings useCase;
  late MockNotificationsRepository mockRepository;

  const testUserId = 'user-123';

  final testSettings = const NotificationSettingsSnapshot(
    allowNotifications: true,
    soundEnabled: true,
    vibrationEnabled: false,
  );

  setUp(() {
    mockRepository = MockNotificationsRepository();
    useCase = GetNotificationSettings(mockRepository);
  });

  test('should return notification settings from repository', () async {
    when(mockRepository.getSettings(testUserId))
        .thenAnswer((_) async => testSettings);

    final result = await useCase(testUserId);

    expect(result, equals(testSettings));
    expect(result.allowNotifications, isTrue);
    expect(result.soundEnabled, isTrue);
    expect(result.vibrationEnabled, isFalse);
    verify(mockRepository.getSettings(testUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.getSettings(testUserId))
        .thenThrow(Exception('Network error'));

    expect(
      () => useCase(testUserId),
      throwsA(isA<Exception>()),
    );
  });
}