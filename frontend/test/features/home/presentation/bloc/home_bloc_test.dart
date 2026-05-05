import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/home/domain/entities/today_habit_entity.dart';
import 'package:habitly/features/home/domain/usecases/get_home_group_filter_options.dart';
import 'package:habitly/features/home/domain/usecases/get_today_habits_for_day.dart';
import 'package:habitly/features/home/domain/usecases/toggle_habit_completion.dart';
import 'package:habitly/features/gamification/domain/usecases/complete_habit.dart';
import 'package:habitly/features/gamification/domain/entities/achievement.dart';
import 'package:habitly/features/home/presentation/bloc/home_bloc.dart';
import 'package:habitly/features/home/presentation/bloc/home_event.dart';
import 'package:habitly/features/home/presentation/bloc/home_state.dart';
import 'package:habitly/features/home/domain/repositories/home_repository.dart';
import 'home_bloc_test.mocks.dart';

@GenerateMocks([
  GetTodayHabitsForDay,
  GetHomeGroupFilterOptions,
  ToggleHabitCompletion,
  CompleteHabit,
])
void main() {
  late HomeBloc bloc;
  late MockGetTodayHabitsForDay mockGetToday;
  late MockGetHomeGroupFilterOptions mockGetGroupOptions;
  late MockToggleHabitCompletion mockToggle;
  late MockCompleteHabit mockCompleteHabit;

  const testUserId = 'user-123';
  final testDay = DateTime(2026, 5, 24);
  final nextDay = DateTime(2026, 5, 25);
  const testGroupId = 'group-456';
  const testHabitId = 'habit-789';

  final testGroupOptions = [
    const HomeGroupFilterOption(groupId: null, title: 'Все группы'),
    const HomeGroupFilterOption(groupId: testGroupId, title: 'Семья'),
  ];

  final testHabits = [
    const TodayHabitEntity(
      id: 'habit-1',
      title: 'Утренняя зарядка',
      completedToday: false,
    ),
    const TodayHabitEntity(
      id: 'habit-2',
      title: 'Чтение книги',
      completedToday: true,
    ),
  ];

  final updatedHabits = [
    const TodayHabitEntity(
      id: 'habit-1',
      title: 'Утренняя зарядка',
      completedToday: true,
    ),
    const TodayHabitEntity(
      id: 'habit-2',
      title: 'Чтение книги',
      completedToday: true,
    ),
  ];

  setUp(() {
    mockGetToday = MockGetTodayHabitsForDay();
    mockGetGroupOptions = MockGetHomeGroupFilterOptions();
    mockToggle = MockToggleHabitCompletion();
    mockCompleteHabit = MockCompleteHabit();

    when(mockGetGroupOptions(testUserId)).thenAnswer((_) async => testGroupOptions);
    when(mockGetToday(
      userId: testUserId,
      day: anyNamed('day'),
      groupId: anyNamed('groupId'),
      forceRefresh: anyNamed('forceRefresh'),
    )).thenAnswer((_) async => testHabits);

    bloc = HomeBloc(
      userId: testUserId,
      getToday: mockGetToday,
      getGroupOptions: mockGetGroupOptions,
      toggle: mockToggle,
      completeHabit: mockCompleteHabit,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('Initial state', () {
    test('should have correct initial state', () {
      expect(bloc.state.selectedDay, isNotNull);
      expect(bloc.state.habits, isEmpty);
      expect(bloc.state.groupOptions, isEmpty);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.selectedGroupId, isNull);
      expect(bloc.state.error, isNull);
      expect(bloc.state.isOffline, isFalse);
    });
  });

  group('HomeLoadRequested', () {
    blocTest<HomeBloc, HomeState>(
      'should load groups and habits on load',
      build: () => bloc,
      act: (bloc) => bloc.add(HomeLoadRequested(testUserId)),
      expect: () => [
        predicate<HomeState>((state) => state.isLoading == true),
        predicate<HomeState>((state) =>
            state.isLoading == false &&
            state.groupOptions.length == 2 &&
            state.habits.length == 2 &&
            state.error == null),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should show offline state on DioException connection error',
      build: () {
        when(mockGetGroupOptions(testUserId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(HomeLoadRequested(testUserId)),
      expect: () => [
        predicate<HomeState>((state) => state.isLoading == true),
        predicate<HomeState>((state) =>
            state.isLoading == false &&
            state.isOffline == true &&
            state.error != null),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should show error on generic exception',
      build: () {
        when(mockGetGroupOptions(testUserId)).thenThrow(Exception('Unexpected'));
        return bloc;
      },
      act: (bloc) => bloc.add(HomeLoadRequested(testUserId)),
      expect: () => [
        predicate<HomeState>((state) => state.isLoading == true),
        predicate<HomeState>((state) =>
            state.isLoading == false && state.error == 'Что-то пошло не так'),
      ],
    );
  });

  group('HomeDateSelected', () {
    blocTest<HomeBloc, HomeState>(
      'should load habits for selected date',
      build: () => bloc,
      seed: () => HomeState(selectedDay: testDay),
      act: (bloc) => bloc.add(HomeDateSelected(nextDay)),
      expect: () => [
        predicate<HomeState>((state) =>
            state.selectedDay == nextDay &&
            state.habits.isEmpty &&
            state.isLoading == true),
        predicate<HomeState>((state) =>
            state.isLoading == false && state.habits.length == 2),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should handle network error on date change',
      build: () {
        when(mockGetToday(
          userId: testUserId,
          day: anyNamed('day'),
          groupId: anyNamed('groupId'),
          forceRefresh: anyNamed('forceRefresh'),
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(HomeDateSelected(nextDay)),
      expect: () => [
        predicate<HomeState>((state) => state.isLoading == true),
        predicate<HomeState>((state) =>
            state.isLoading == false && state.isOffline == true),
      ],
    );
  });

  group('HomeGroupFilterSelected', () {
    blocTest<HomeBloc, HomeState>(
      'should load habits filtered by group',
      build: () => bloc,
      act: (bloc) => bloc.add(HomeGroupFilterSelected(testGroupId)),
      expect: () => [
        predicate<HomeState>((state) =>
            state.selectedGroupId == testGroupId && state.isLoading == true),
        predicate<HomeState>((state) =>
            state.isLoading == false && state.habits.length == 2),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should clear filter when groupId = null',
      build: () => bloc,
      act: (bloc) => bloc.add(HomeGroupFilterSelected(null)),
      expect: () => [
        predicate<HomeState>((state) =>
            state.selectedGroupId == null && state.isLoading == true),
        predicate<HomeState>((state) =>
            state.isLoading == false && state.habits.length == 2),
      ],
    );
  });

  group('HomeHabitToggled', () {
    blocTest<HomeBloc, HomeState>(
      'should toggle habit completion (completed = true)',
      build: () {
        when(mockCompleteHabit(any)).thenAnswer((_) async => const Right(<NewAchievementInfo>[]));
        when(mockGetToday(
          userId: testUserId,
          day: anyNamed('day'),
          groupId: anyNamed('groupId'),
          forceRefresh: true,
        )).thenAnswer((_) async => updatedHabits);
        return bloc;
      },
      seed: () => HomeState(
        selectedDay: testDay,
        habits: testHabits,
        groupOptions: testGroupOptions,
      ),
      act: (bloc) => bloc.add(HomeHabitToggled(habitId: 'habit-1', completed: true)),
      expect: () => [
        predicate<HomeState>((state) =>
            state.habits.any((h) => h.id == 'habit-1' && h.completedToday == true)),
        predicate<HomeState>((state) =>
            state.habits.every((h) => h.completedToday == true)),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should toggle habit completion (completed = false)',
      build: () {
        when(mockToggle(
          habitId: 'habit-2',
          userId: testUserId,
          day: anyNamed('day'),
          completed: false,
        )).thenAnswer((_) async => {});
        when(mockGetToday(
          userId: testUserId,
          day: anyNamed('day'),
          groupId: anyNamed('groupId'),
          forceRefresh: true,
        )).thenAnswer((_) async => testHabits);
        return bloc;
      },
      seed: () => HomeState(
        selectedDay: testDay,
        habits: testHabits,
        groupOptions: testGroupOptions,
      ),
      act: (bloc) => bloc.add(HomeHabitToggled(habitId: 'habit-2', completed: false)),
      expect: () => [
        predicate<HomeState>((state) =>
            state.habits.any((h) => h.id == 'habit-2' && h.completedToday == false)),
        predicate<HomeState>((state) => state.habits.isNotEmpty && !state.isLoading),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'should rollback on error',
      build: () {
        when(mockCompleteHabit(any)).thenThrow(Exception('Network error'));
        return bloc;
      },
      seed: () => HomeState(
        selectedDay: testDay,
        habits: testHabits,
        groupOptions: testGroupOptions,
      ),
      act: (bloc) => bloc.add(HomeHabitToggled(habitId: 'habit-1', completed: true)),
      expect: () => [
        predicate<HomeState>((state) =>
            state.habits.any((h) => h.id == 'habit-1' && h.completedToday == true)),
        predicate<HomeState>((state) =>
            state.habits.firstWhere((h) => h.id == 'habit-1').completedToday == false &&
            state.error != null),
      ],
    );
  });
}