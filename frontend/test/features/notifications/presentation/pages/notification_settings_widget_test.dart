import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/notifications/domain/entities/notification_settings_snapshot.dart';
import 'package:habitly/features/notifications/domain/usecases/bootstrap_notification_pipeline.dart';
import 'package:habitly/features/notifications/domain/usecases/get_notification_settings.dart';
import 'package:habitly/features/notifications/domain/usecases/save_notification_settings.dart';
import 'package:habitly/features/notifications/presentation/cubit/notification_settings_cubit.dart';
import 'package:habitly/features/notifications/presentation/pages/notification_settings_page.dart';

import 'notification_settings_widget_test.mocks.dart';

@GenerateMocks([
  BootstrapNotificationPipeline,
  GetNotificationSettings,
  SaveNotificationSettings,
])
void main() {
  late MockGetNotificationSettings mockGetSettings;
  late MockSaveNotificationSettings mockSaveSettings;
  late MockBootstrapNotificationPipeline mockBootstrapPipeline;
  late NotificationSettingsCubit cubit;

  const testUserId = 'user-123';
  const enabledState = NotificationSettingsSnapshot(
    allowNotifications: true,
    soundEnabled: true,
    vibrationEnabled: true,
  );

  setUp(() {
    mockGetSettings = MockGetNotificationSettings();
    mockSaveSettings = MockSaveNotificationSettings();
    mockBootstrapPipeline = MockBootstrapNotificationPipeline();

    when(mockGetSettings(testUserId)).thenAnswer((_) async => enabledState);
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

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: NotificationSettingsPage(
        userId: testUserId,
        settingsCubit: cubit,
      ),
    );
  }

  group('NotificationSettingsPage', () {
    testWidgets('displays all three settings tiles', (tester) async {
      await cubit.load();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Отправлять уведомления'), findsOneWidget);
      expect(find.text('Звук'), findsOneWidget);
      expect(find.text('Вибрация'), findsOneWidget);
    });

    testWidgets('calls setAllow when global switch toggled', (tester) async {
      await cubit.load();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      verify(mockSaveSettings(testUserId, any)).called(1);
      expect(cubit.state.allowNotifications, isFalse);
    });
  });
}
