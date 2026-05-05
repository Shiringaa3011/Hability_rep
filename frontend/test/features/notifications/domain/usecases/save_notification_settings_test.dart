import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/notifications/domain/entities/notification_settings_snapshot.dart';
import 'package:habitly/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:habitly/features/notifications/domain/usecases/save_notification_settings.dart';

import 'save_notification_settings_test.mocks.dart';

@GenerateMocks([NotificationsRepository])
void main() {
  late SaveNotificationSettings useCase;
  late MockNotificationsRepository mockRepository;

  const testUserId = 'user-123';
  const testSettings = NotificationSettingsSnapshot(
    allowNotifications: true,
    soundEnabled: false,
    vibrationEnabled: true,
  );

  setUp(() {
    mockRepository = MockNotificationsRepository();
    useCase = SaveNotificationSettings(mockRepository);
  });

  test('should call repository.saveSettings with correct parameters', () async {
    when(mockRepository.saveSettings(testUserId, testSettings))
        .thenAnswer((_) async => {});

    await useCase(testUserId, testSettings);

    verify(mockRepository.saveSettings(testUserId, testSettings)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.saveSettings(testUserId, testSettings))
        .thenThrow(Exception('Network error'));

    expect(
      () => useCase(testUserId, testSettings),
      throwsA(isA<Exception>()),
    );
  });
}