import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/home/domain/entities/today_habit_entity.dart';
import 'package:habitly/features/home/domain/usecases/get_home_group_filter_options.dart';
import 'package:habitly/features/home/domain/usecases/get_habit_by_id.dart';
import 'package:habitly/features/home/domain/usecases/upsert_habit_definition.dart';
import 'package:habitly/features/home/domain/usecases/delete_habit.dart';
import 'package:habitly/features/habits/presentation/pages/edit_habit_page.dart';
import 'package:habitly/features/home/domain/repositories/home_repository.dart';
import 'edit_habit_page_test.mocks.dart';

@GenerateMocks([
  GetHabitById,
  GetHomeGroupFilterOptions,
  UpsertHabitDefinition,
  DeleteHabitUseCase,
])
void main() {
  late MockGetHabitById mockGetHabitById;
  late MockGetHomeGroupFilterOptions mockGetHomeGroupFilterOptions;
  late MockUpsertHabitDefinition mockUpsertHabitDefinition;
  late MockDeleteHabitUseCase mockDeleteHabitUseCase;

  const testUserId = 'user-123';
  const testHabitId = 'habit-456';

  final List<HomeGroupFilterOption> testGroups = [
    const HomeGroupFilterOption(groupId: 'group-1', title: 'Семья'),
    const HomeGroupFilterOption(groupId: 'group-2', title: 'Друзья'),
    const HomeGroupFilterOption(groupId: null, title: 'Все привычки'),
  ];

  final testHabitDaily = TodayHabitEntity(
    id: testHabitId,
    title: 'Утренняя зарядка',
    description: 'Делать зарядку каждое утро',
    scheduledTimeLabel: '08:00',
    frequencyLabel: 'Ежедневно',
    groupId: null,
    groupName: null,
    remindersEnabled: true,
    reminderTimeLabel: '07:55',
    dayOfWeek: null,
  );

  final testHabitWeekly = TodayHabitEntity(
    id: testHabitId,
    title: 'Занятия английским',
    description: 'Учить новые слова',
    scheduledTimeLabel: '19:00',
    frequencyLabel: 'Еженедельно',
    groupId: 'group-1',
    groupName: 'Семья',
    remindersEnabled: false,
    reminderTimeLabel: null,
    dayOfWeek: 3,
  );

  final testHabitWithReminders = TodayHabitEntity(
    id: testHabitId,
    title: 'Медитация',
    description: '10 минут тишины',
    scheduledTimeLabel: '09:00',
    frequencyLabel: 'Ежедневно',
    groupId: null,
    groupName: null,
    remindersEnabled: true,
    reminderTimeLabel: '08:50',
    dayOfWeek: null,
  );

  String localTimeFromUtcLabel(String utcLabel) {
    final parts = utcLabel.split(':');
    final utc = DateTime.utc(
      2026,
      1,
      1,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final local = utc.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  setUp(() {
    mockGetHabitById = MockGetHabitById();
    mockGetHomeGroupFilterOptions = MockGetHomeGroupFilterOptions();
    mockUpsertHabitDefinition = MockUpsertHabitDefinition();
    mockDeleteHabitUseCase = MockDeleteHabitUseCase();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: EditHabitPage(
        userId: testUserId,
        habitId: testHabitId,
        getHabitById: mockGetHabitById,
        getHomeGroupFilterOptions: mockGetHomeGroupFilterOptions,
        upsertHabitDefinition: mockUpsertHabitDefinition,
        deleteHabitUseCase: mockDeleteHabitUseCase,
      ),
    );
  }

  Finder saveButton() => find.byKey(const Key('habit_save_button'));

  Future<void> pumpUntilFormReady(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      saveButton(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(saveButton());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Finder deleteButton() => find.byKey(const Key('habit_delete_button'));

  Future<void> tapDelete(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      deleteButton(),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(deleteButton());
    await tester.pump();
  }

  group('EditHabitPage - loading state', () {
    testWidgets('shows loading indicator while loading data', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error when habit not found', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => null);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);

      await pumpUntilFormReady(tester);

      expect(find.text('Привычка не найдена'), findsOneWidget);
    });

    testWidgets('handles loading error gracefully', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenThrow(Exception('Network error'));
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenThrow(Exception('Network error'));

      await pumpUntilFormReady(tester);

      expect(find.text('Привычка не найдена'), findsOneWidget);
    });
  });

  group('EditHabitPage - display habit data', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('displays daily habit data correctly', (tester) async {
      await pumpUntilFormReady(tester);

      expect(find.text('Изменить привычку'), findsOneWidget);
      expect(find.text('Утренняя зарядка'), findsOneWidget);
      expect(find.text('Делать зарядку каждое утро'), findsOneWidget);
      expect(find.text(localTimeFromUtcLabel('08:00')), findsOneWidget);
      expect(find.text('Ежедневно'), findsOneWidget);
    });

    testWidgets('displays weekly habit data correctly', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitWeekly);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);

      await pumpUntilFormReady(tester);

      expect(find.text('Занятия английским'), findsOneWidget);
      expect(find.text('Учить новые слова'), findsOneWidget);
      expect(find.text(localTimeFromUtcLabel('19:00')), findsOneWidget);
      expect(find.text('Еженедельно'), findsOneWidget);
      expect(find.text('Ср'), findsOneWidget);
    });

    testWidgets('displays group info correctly', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitWeekly);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);

      await pumpUntilFormReady(tester);

      final dropdown = find.byType(DropdownButtonFormField<String?>);
      expect(dropdown, findsOneWidget);
    });

    testWidgets('displays reminder info when enabled', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitWithReminders);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);

      await pumpUntilFormReady(tester);

      expect(find.text('Время напоминания'), findsOneWidget);
      expect(find.text(localTimeFromUtcLabel('08:50')), findsOneWidget);
    });
  });

  group('EditHabitPage - form validation', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});
    });

    testWidgets('shows validation error when title empty', (tester) async {
      await pumpUntilFormReady(tester);

      await tester.enterText(find.byType(TextFormField).first, '   ');
      await tester.pump();

      await tester.scrollUntilVisible(
        saveButton(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
    });

    testWidgets('shows error when weekly day not selected', (tester) async {
      await pumpUntilFormReady(tester);

      await tester.tap(find.text('Еженедельно'));
      await tester.pump();

      await tapSave(tester);

      expect(find.text('Выберите день недели'), findsOneWidget);
    });

    testWidgets('allows save when all required fields filled', (tester) async {
      await pumpUntilFormReady(tester);

      await tapSave(tester);

      verify(mockUpsertHabitDefinition(any, any)).called(1);
    });
  });

  group('EditHabitPage - save habit', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('saves daily habit successfully', (tester) async {
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});

      await pumpUntilFormReady(tester);

      await tapSave(tester);

      verify(mockUpsertHabitDefinition(any, any)).called(1);
    });

    testWidgets('saves weekly habit with selected day', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitWeekly);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});

      await pumpUntilFormReady(tester);

      await tapSave(tester);

      verify(mockUpsertHabitDefinition(any, any)).called(1);
    });

    testWidgets('shows error when save fails', (tester) async {
      when(mockUpsertHabitDefinition(any, any))
          .thenThrow(Exception('Network error'));

      await pumpUntilFormReady(tester);

      await tapSave(tester);

      expect(
        find.text('Не удалось сохранить изменения. Проверьте подключение к интернету.'),
        findsOneWidget,
      );
    });
  });

  group('EditHabitPage - delete habit', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('shows confirmation dialog when delete pressed', (tester) async {
      when(mockDeleteHabitUseCase(testHabitId, testUserId))
          .thenAnswer((_) async => {});

      await pumpUntilFormReady(tester);

      await tapDelete(tester);

      expect(find.text('Удалить привычку?'), findsOneWidget);
      expect(find.text('Это действие нельзя отменить.'), findsOneWidget);
      expect(find.text('Нет'), findsOneWidget);
      expect(find.text('Да'), findsOneWidget);
    });

    testWidgets('deletes habit when confirmed', (tester) async {
      when(mockDeleteHabitUseCase(testHabitId, testUserId))
          .thenAnswer((_) async => {});

      await pumpUntilFormReady(tester);

      await tapDelete(tester);

      await tester.tap(find.text('Да'));
      await tester.pump();

      verify(mockDeleteHabitUseCase(testHabitId, testUserId)).called(1);
    });

    testWidgets('does not delete when cancelled', (tester) async {
      await pumpUntilFormReady(tester);

      await tapDelete(tester);

      await tester.tap(find.text('Нет'));
      await tester.pump();

      verifyNever(mockDeleteHabitUseCase(any, any));
    });

    testWidgets('shows error when delete fails', (tester) async {
      when(mockDeleteHabitUseCase(testHabitId, testUserId))
          .thenThrow(Exception('Network error'));

      await pumpUntilFormReady(tester);

      await tapDelete(tester);

      await tester.tap(find.text('Да'));
      await tester.pump();

      expect(
        find.text('Не удалось удалить привычку. Проверьте подключение к интернету.'),
        findsOneWidget,
      );
    });
  });

  group('EditHabitPage - frequency selection', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('can change frequency from daily to weekly', (tester) async {
      await pumpUntilFormReady(tester);

      expect(find.text('Пн'), findsNothing);

      await tester.tap(find.text('Еженедельно'));
      await tester.pump();

      expect(find.text('Пн'), findsOneWidget);
      expect(find.text('Вт'), findsOneWidget);
    });

    testWidgets('can change frequency from weekly to daily', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitWeekly);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);

      await pumpUntilFormReady(tester);

      expect(find.text('Пн'), findsOneWidget);

      await tester.tap(find.text('Ежедневно'));
      await tester.pump();

      expect(find.text('Пн'), findsNothing);
    });
  });

  group('EditHabitPage - group dropdown', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitWeekly);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('group dropdown is disabled (onChanged = null)', (tester) async {
      await pumpUntilFormReady(tester);

      final dropdown = find.byType(DropdownButtonFormField<String?>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pump();

      expect(find.text('Личная привычка'), findsNothing);
    });

    testWidgets('shows helper text that group cannot be changed', (tester) async {
      await pumpUntilFormReady(tester);

      expect(
        find.text('Группу нельзя изменить после создания привычки'),
        findsOneWidget,
      );
    });
  });

  group('EditHabitPage - time picker', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('opens time picker when schedule button tapped', (tester) async {
      await pumpUntilFormReady(tester);

      final scheduleButton = find.byIcon(Icons.schedule);
      expect(scheduleButton, findsOneWidget);

      await tester.tap(scheduleButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });

  group('EditHabitPage - reminders', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('can enable reminders', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);

      await pumpUntilFormReady(tester);

      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);

      await tester.tap(switchTile);
      await tester.pump();

      expect(find.text('Время напоминания'), findsOneWidget);
    });

    testWidgets('opens reminder time picker when alarm button tapped', (tester) async {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitWithReminders);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);

      await pumpUntilFormReady(tester);

      final alarmButton = find.byIcon(Icons.alarm);
      expect(alarmButton, findsOneWidget);

      await tester.tap(alarmButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });

  group('EditHabitPage - UI elements', () {
    setUp(() {
      when(mockGetHabitById(testHabitId, testUserId))
          .thenAnswer((_) async => testHabitDaily);
      when(mockGetHomeGroupFilterOptions(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('displays all form fields', (tester) async {
      await pumpUntilFormReady(tester);

      expect(find.text('Изменить привычку'), findsOneWidget);
      expect(find.text('Название *'), findsOneWidget);
      expect(find.text('Описание'), findsOneWidget);
      expect(find.text('Периодичность'), findsOneWidget);
      expect(find.text('Ежедневно'), findsOneWidget);
      expect(find.text('Еженедельно'), findsOneWidget);
      expect(find.text('Группа'), findsOneWidget);
      expect(find.text('Напоминания'), findsOneWidget);
      expect(find.text('Сохранить'), findsOneWidget);
      expect(find.text('Удалить привычку'), findsOneWidget);
    });

    testWidgets('save button is enabled when title filled', (tester) async {
      await pumpUntilFormReady(tester);

      await tester.scrollUntilVisible(
        saveButton(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNotNull);
    });

    testWidgets('displays delete button with destructive style', (tester) async {
      await pumpUntilFormReady(tester);

      await tester.scrollUntilVisible(
        deleteButton(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('habit_delete_button')), findsOneWidget);
    });
  });
}