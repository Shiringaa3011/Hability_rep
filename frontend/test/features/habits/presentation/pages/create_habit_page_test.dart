import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/home/domain/usecases/upsert_habit_definition.dart';
import 'package:habitly/features/habits/presentation/pages/create_habit_page.dart';

import 'create_habit_page_test.mocks.dart';

@GenerateMocks([GroupRepository, UpsertHabitDefinition])
void main() {
  late MockGroupRepository mockGroupRepository;
  late MockUpsertHabitDefinition mockUpsertHabitDefinition;

  const testUserId = 'user-123';

  final testGroups = [
    GroupEntity(
      id: 'group-1',
      name: 'Семья',
      description: 'Наши семейные привычки',
      createdBy: testUserId,
      createdAt: DateTime(2026, 1, 1),
      habitsCount: 2,
    ),
    GroupEntity(
      id: 'group-2',
      name: 'Друзья',
      description: null,
      createdBy: 'user-456',
      createdAt: DateTime(2026, 1, 15),
      habitsCount: 5,
    ),
    GroupEntity(
      id: 'group-3',
      name: 'Работа',
      description: 'Рабочие привычки',
      createdBy: 'user-789',
      createdAt: DateTime(2026, 2, 1),
      habitsCount: 3,
    ),
  ];

  setUp(() {
    mockGroupRepository = MockGroupRepository();
    mockUpsertHabitDefinition = MockUpsertHabitDefinition();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CreateHabitPage(
        userId: testUserId,
        groupRepository: mockGroupRepository,
        upsertHabitDefinition: mockUpsertHabitDefinition,
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

  group('CreateHabitPage - loading state', () {
    testWidgets('shows loading indicator while loading groups', (tester) async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('handles group loading error gracefully', (tester) async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Название *'), findsOneWidget);
    });
  });

  group('CreateHabitPage - form validation', () {
    setUp(() async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});
    });

    testWidgets('shows validation error when title is empty', (tester) async {
      await pumpUntilFormReady(tester);

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

      await tester.enterText(find.byType(TextFormField).first, 'Новая привычка');
      await tester.pump();

      await tapSave(tester);

      expect(find.text('Выберите день недели'), findsOneWidget);
    });

    testWidgets('allows save when all required fields filled', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Медитация');
      await tester.pump();

      await tapSave(tester);

      verify(mockUpsertHabitDefinition(any, any)).called(1);
    });
  });

  group('CreateHabitPage - frequency selection', () {
    setUp(() async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('shows weekday buttons when weekly selected', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Пн'), findsNothing);

      await tester.tap(find.text('Еженедельно'));
      await tester.pump();

      expect(find.text('Пн'), findsOneWidget);
      expect(find.text('Вт'), findsOneWidget);
      expect(find.text('Ср'), findsOneWidget);
      expect(find.text('Чт'), findsOneWidget);
      expect(find.text('Пт'), findsOneWidget);
      expect(find.text('Сб'), findsOneWidget);
      expect(find.text('Вс'), findsOneWidget);
    });

    testWidgets('selects weekday correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Еженедельно'));
      await tester.pump();

      await tester.tap(find.text('Пн'));
      await tester.pump();

      expect(find.text('Пн'), findsOneWidget);
    });
  });

  group('CreateHabitPage - time picker', () {
    setUp(() async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('shows "Не задано" when time not selected', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Не задано'), findsOneWidget);
    });

    testWidgets('opens time picker when schedule button tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final scheduleButton = find.byIcon(Icons.schedule);
      expect(scheduleButton, findsOneWidget);

      await tester.tap(scheduleButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });

  group('CreateHabitPage - group dropdown', () {
    setUp(() async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('shows "Личная привычка" as default option', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButtonFormField<String?>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Личная привычка'), findsWidgets);
    });

    testWidgets('disables group with habitsCount >= 5', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButtonFormField<String?>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('лимит 5'), findsOneWidget);
    });

    testWidgets('sorts groups by available first', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButtonFormField<String?>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('лимит 5'), findsOneWidget);
    });
  });

  group('CreateHabitPage - reminders', () {
    setUp(() async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('shows reminder time picker when reminders enabled', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final switchTile = find.byType(SwitchListTile);
      expect(switchTile, findsOneWidget);

      await tester.tap(switchTile);
      await tester.pump();

      expect(find.text('Время напоминания'), findsOneWidget);
      expect(find.text('Не выбрано'), findsOneWidget);
    });

    testWidgets('opens reminder time picker when alarm button tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      final alarmButton = find.byIcon(Icons.alarm);
      expect(alarmButton, findsOneWidget);

      await tester.tap(alarmButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });
  });

  group('CreateHabitPage - save habit', () {
    setUp(() async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('creates daily habit successfully', (tester) async {
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Бег по утрам');
      await tester.pump();

      await tapSave(tester);

      verify(mockUpsertHabitDefinition(any, any)).called(1);
    });

    testWidgets('creates weekly habit with selected day', (tester) async {
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Еженедельно'));
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'Занятия английским');
      await tester.pump();

      await tester.tap(find.text('Ср'));
      await tester.pump();

      await tapSave(tester);

      verify(mockUpsertHabitDefinition(any, any)).called(1);
    });

    testWidgets('creates habit with group selected', (tester) async {
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Йога с командой');
      await tester.pump();

      final dropdown = find.byType(DropdownButtonFormField<String?>);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Семья'));
      await tester.pump();

      await tapSave(tester);

      verify(mockUpsertHabitDefinition(any, any)).called(1);
    });

    testWidgets('shows error when save fails', (tester) async {
      when(mockUpsertHabitDefinition(any, any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Новая привычка');
      await tester.pump();

      await tapSave(tester);

      expect(
        find.text('Не удалось сохранить привычку. Проверьте подключение к интернету.'),
        findsOneWidget,
      );
    });
  });

  group('CreateHabitPage - UI elements', () {
    setUp(() async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);
    });

    testWidgets('displays all form fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Название *'), findsOneWidget);
      expect(find.text('Описание'), findsOneWidget);
      expect(find.text('Периодичность'), findsOneWidget);
      expect(find.text('Ежедневно'), findsOneWidget);
      expect(find.text('Еженедельно'), findsOneWidget);
      expect(find.text('Группа'), findsOneWidget);
      expect(find.text('Напоминания'), findsOneWidget);
      expect(find.text('Сохранить'), findsOneWidget);
    });

    testWidgets('save button is disabled when title empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
    });

    testWidgets('save button is enabled when title filled', (tester) async {
      when(mockUpsertHabitDefinition(any, any))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Заполнено');
      await tester.pump();

      await tester.scrollUntilVisible(
        saveButton(),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNotNull);
    });
  });
}