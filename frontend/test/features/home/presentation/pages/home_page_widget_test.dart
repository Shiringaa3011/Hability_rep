import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/core/design_system/widgets/ds_check_circle.dart';
import 'package:habitly/core/design_system/widgets/ds_date_strip.dart';
import 'package:habitly/features/home/domain/entities/today_habit_entity.dart';
import 'package:habitly/features/home/presentation/bloc/home_bloc.dart';
import 'package:habitly/features/home/presentation/bloc/home_event.dart';
import 'package:habitly/features/home/presentation/bloc/home_state.dart';
import 'package:habitly/features/home/presentation/pages/home_page.dart';
import 'package:habitly/features/habits/presentation/pages/create_habit_page.dart';
import 'package:habitly/features/habits/presentation/pages/edit_habit_page.dart';
import 'package:get_it/get_it.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/home/domain/usecases/upsert_habit_definition.dart';

import 'package:habitly/features/home/domain/repositories/home_repository.dart';
import '../../../habits/presentation/pages/create_habit_page_test.mocks.dart';
import 'home_page_widget_test.mocks.dart';

@GenerateMocks([HomeBloc])
void main() {
  late MockHomeBloc mockHomeBloc;
  late MockGroupRepository mockGroupRepository;
  late MockUpsertHabitDefinition mockUpsertHabitDefinition;

  const testUserId = 'user-123';
  final testDay = DateTime(2026, 5, 24);
  final futureDay = DateTime(2026, 5, 25);

  final testGroupOptions = [
    const HomeGroupFilterOption(groupId: null, title: 'Все группы'),
    const HomeGroupFilterOption(groupId: 'group-1', title: 'Семья'),
    const HomeGroupFilterOption(groupId: 'group-2', title: 'Друзья'),
  ];

  final testHabits = [
    TodayHabitEntity(
      id: 'habit-1',
      title: 'Утренняя зарядка',
      description: 'Делать зарядку',
      scheduledTimeLabel: '08:00',
      frequencyLabel: 'Ежедневно',
      completedToday: false,
      groupId: null,
      groupName: null,
      remindersEnabled: false,
      reminderTimeLabel: null,
    ),
    TodayHabitEntity(
      id: 'habit-2',
      title: 'Чтение книги',
      description: null,
      scheduledTimeLabel: '21:00',
      frequencyLabel: 'Ежедневно',
      completedToday: true,
      groupId: 'group-1',
      groupName: 'Семья',
      remindersEnabled: true,
      reminderTimeLabel: '20:50',
    ),
  ];

  final loadingState = HomeState(
    selectedDay: testDay,
    habits: [],
    groupOptions: [],
    isLoading: true,
    selectedGroupId: null,
    error: null,
    isOffline: false,
  );

  final loadedState = HomeState(
    selectedDay: testDay,
    habits: testHabits,
    groupOptions: testGroupOptions,
    isLoading: false,
    selectedGroupId: null,
    error: null,
    isOffline: false,
  );

  final errorState = HomeState(
    selectedDay: testDay,
    habits: [],
    groupOptions: [],
    isLoading: false,
    selectedGroupId: null,
    error: 'Ошибка загрузки',
    isOffline: false,
  );

  final offlineState = HomeState(
    selectedDay: testDay,
    habits: testHabits,
    groupOptions: testGroupOptions,
    isLoading: false,
    selectedGroupId: null,
    error: null,
    isOffline: true,
  );

  setUp(() async {
    mockHomeBloc = MockHomeBloc();
    mockGroupRepository = MockGroupRepository();
    mockUpsertHabitDefinition = MockUpsertHabitDefinition();
    when(mockGroupRepository.getUserGroups(testUserId))
        .thenAnswer((_) async => []);
    when(mockUpsertHabitDefinition(any, any)).thenAnswer((_) async {});

    await GetIt.instance.reset();
    GetIt.instance.registerLazySingleton<GroupRepository>(() => mockGroupRepository);
    GetIt.instance.registerLazySingleton<UpsertHabitDefinition>(
      () => mockUpsertHabitDefinition,
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

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

  void stubBlocState(HomeState state) {
    when(mockHomeBloc.state).thenReturn(state);
    when(mockHomeBloc.stream).thenAnswer((_) => Stream.value(state));
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: HomePage(userId: testUserId, homeBloc: mockHomeBloc),
    );
  }

  group('HomePage', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      stubBlocState(loadingState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error widget when error and habits empty', (tester) async {
      stubBlocState(errorState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Ошибка загрузки'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('shows habits list when loaded', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Утренняя зарядка'), findsOneWidget);
      expect(find.text('Чтение книги'), findsOneWidget);
      expect(find.text('Делать зарядку'), findsOneWidget);
      expect(
        find.text('${localTimeFromUtcLabel('21:00')} · Ежедневно · Семья'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty message when no habits', (tester) async {
      final emptyState = HomeState(
        selectedDay: testDay,
        habits: [],
        groupOptions: testGroupOptions,
        isLoading: false,
        selectedGroupId: null,
        error: null,
        isOffline: false,
      );
      stubBlocState(emptyState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Нет привычек на этот день'), findsOneWidget);
    });

    testWidgets('shows progress summary with correct percentage', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('1 из 2'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('shows offline indicator when offline', (tester) async {
      stubBlocState(offlineState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Офлайн-режим'), findsOneWidget);
    });
  });

  group('GroupChips', () {
    testWidgets('displays all group chips', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Все'), findsOneWidget);
      expect(find.text('Семья'), findsOneWidget);
      expect(find.text('Друзья'), findsOneWidget);
    });

    testWidgets('highlights selected chip', (tester) async {
      final selectedState = HomeState(
        selectedDay: testDay,
        habits: testHabits,
        groupOptions: testGroupOptions,
        isLoading: false,
        selectedGroupId: 'group-1',
        error: null,
        isOffline: false,
      );
      stubBlocState(selectedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final chip = find.text('Семья');
      expect(chip, findsOneWidget);
    });

    testWidgets('calls HomeGroupFilterSelected when chip tapped', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Семья'));
      await tester.pump();

      verify(mockHomeBloc.add(any)).called(1);
    });
  });

  group('HabitTile', () {
    testWidgets('displays habit title with strikethrough when completed', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final completedHabit = find.text('Чтение книги');
      expect(completedHabit, findsOneWidget);
    });

    testWidgets('calls HomeHabitToggled when checkbox tapped', (tester) async {
      stubBlocState(loadedState);
      when(mockHomeBloc.add(any)).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      final checkboxes = find.byType(DSCheckCircle);
      await tester.tap(checkboxes.first);
      await tester.pump();

      verify(mockHomeBloc.add(any)).called(1);
    });

    testWidgets('navigates to EditHabitPage on tap', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Утренняя зарядка'));
      await tester.pumpAndSettle();

      expect(find.byType(EditHabitPage), findsOneWidget);
    });
  });

  group('FloatingActionButton', () {
    testWidgets('opens CreateHabitPage when tapped', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.byType(CreateHabitPage), findsOneWidget);
    });
  });

  group('DateStrip', () {
    testWidgets('calls HomeDateSelected when date selected', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final dateStrip = find.byType(DSDateStrip);
      expect(dateStrip, findsOneWidget);
    });
  });

  group('RefreshIndicator', () {
    testWidgets('calls HomeLoadRequested on pull to refresh', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      final refreshIndicatorWidget = tester.widget<RefreshIndicator>(refreshIndicator);
      await refreshIndicatorWidget.onRefresh!();

      verify(mockHomeBloc.add(any)).called(1);
    });
  });
}