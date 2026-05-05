import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/notifications/domain/entities/notification_settings_snapshot.dart';
import 'package:habitly/features/notifications/domain/usecases/bootstrap_notification_pipeline.dart';
import 'package:habitly/features/notifications/domain/usecases/get_notification_settings.dart';
import 'package:habitly/features/notifications/domain/usecases/save_notification_settings.dart';
import 'package:habitly/features/notifications/presentation/cubit/notification_settings_cubit.dart';

import 'notification_settings_cubit_test.mocks.dart';

@GenerateMocks([
  BootstrapNotificationPipeline,
  GetNotificationSettings,
  SaveNotificationSettings,
])
void main() {
  late NotificationSettingsCubit cubit;
  late MockGetNotificationSettings mockGetSettings;
  late MockSaveNotificationSettings mockSaveSettings;
  late MockBootstrapNotificationPipeline mockBootstrapPipeline;

  const testUserId = 'user-123';
  const testSettings = NotificationSettingsSnapshot(
    allowNotifications: true,
    soundEnabled: true,
    vibrationEnabled: false,
  );

  setUp(() {
    mockGetSettings = MockGetNotificationSettings();
    mockSaveSettings = MockSaveNotificationSettings();
    mockBootstrapPipeline = MockBootstrapNotificationPipeline();

    when(mockGetSettings(testUserId)).thenAnswer((_) async => testSettings);
    when(mockSaveSettings(testUserId, any)).thenAnswer((_) async => {});

    cubit = NotificationSettingsCubit(
      userId: testUserId,
      bootstrapPipeline: mockBootstrapPipeline,
      getSettings: mockGetSettings,
      saveSettings: mockSaveSettings,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('Initial state', () {
    test('should have default settings', () {
      expect(cubit.state.allowNotifications, isTrue);
      expect(cubit.state.soundEnabled, isTrue);
      expect(cubit.state.vibrationEnabled, isTrue);
    });
  });

  group('load', () {
    blocTest<NotificationSettingsCubit, NotificationSettingsSnapshot>(
      'should emit loaded settings from repository',
      build: () => cubit,
      act: (cubit) => cubit.load(),
      expect: () => [testSettings],
    );
  });

  group('setAllow', () {
    blocTest<NotificationSettingsCubit, NotificationSettingsSnapshot>(
      'should update allowNotifications and save',
      build: () => cubit,
      act: (cubit) => cubit.setAllow(false),
      expect: () => [
        predicate<NotificationSettingsSnapshot>((state) =>
            state.allowNotifications == false &&
            state.soundEnabled == true &&
            state.vibrationEnabled == true),
      ],
      verify: (_) {
        verify(mockSaveSettings(testUserId, any)).called(1);
      },
    );
  });

  group('setSound', () {
    blocTest<NotificationSettingsCubit, NotificationSettingsSnapshot>(
      'should update soundEnabled and save',
      build: () => cubit,
      act: (cubit) => cubit.setSound(false),
      expect: () => [
        predicate<NotificationSettingsSnapshot>((state) =>
            state.allowNotifications == true &&
            state.soundEnabled == false &&
            state.vibrationEnabled == true),
      ],
      verify: (_) {
        verify(mockSaveSettings(testUserId, any)).called(1);
      },
    );
  });

  group('setVibration', () {
    blocTest<NotificationSettingsCubit, NotificationSettingsSnapshot>(
      'should update vibrationEnabled and save',
      build: () => cubit,
      act: (cubit) => cubit.setVibration(true),
      expect: () => [
        predicate<NotificationSettingsSnapshot>((state) =>
            state.allowNotifications == true &&
            state.soundEnabled == true &&
            state.vibrationEnabled == true),
      ],
      verify: (_) {
        verify(mockSaveSettings(testUserId, any)).called(1);
      },
    );
  });
}