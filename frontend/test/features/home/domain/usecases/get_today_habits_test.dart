import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/home/domain/entities/today_habit_entity.dart';
import 'package:habitly/features/home/domain/repositories/home_repository.dart';
import 'package:habitly/features/home/domain/usecases/get_today_habits_for_day.dart';

import 'get_today_habits_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late GetTodayHabitsForDay useCase;
  late MockHomeRepository mockRepository;

  const testUserId = 'user-123';
  final testDay = DateTime(2026, 5, 24);
  const testGroupId = 'group-456';

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

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetTodayHabitsForDay(mockRepository);
  });

  test('should return habits from repository with default parameters', () async {
    when(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: null,
      forceRefresh: false,
    )).thenAnswer((_) async => testHabits);

    final result = await useCase(
      userId: testUserId,
      day: testDay,
    );

    expect(result, equals(testHabits));
    expect(result.length, equals(2));
    verify(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: null,
      forceRefresh: false,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should pass groupId to repository', () async {
    when(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: testGroupId,
      forceRefresh: false,
    )).thenAnswer((_) async => testHabits.where((h) => h.groupId == testGroupId).toList());

    final result = await useCase(
      userId: testUserId,
      day: testDay,
      groupId: testGroupId,
    );

    verify(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: testGroupId,
      forceRefresh: false,
    )).called(1);
  });

  test('should pass forceRefresh to repository', () async {
    when(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: null,
      forceRefresh: true,
    )).thenAnswer((_) async => testHabits);

    await useCase(
      userId: testUserId,
      day: testDay,
      forceRefresh: true,
    );

    verify(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: null,
      forceRefresh: true,
    )).called(1);
  });

  test('should return empty list when repository returns empty', () async {
    when(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: null,
      forceRefresh: false,
    )).thenAnswer((_) async => []);

    final result = await useCase(
      userId: testUserId,
      day: testDay,
    );

    expect(result, isEmpty);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.getHabitsForDay(
      userId: testUserId,
      day: testDay,
      groupId: null,
      forceRefresh: false,
    )).thenThrow(Exception('Network error'));

    expect(
      () => useCase(
        userId: testUserId,
        day: testDay,
      ),
      throwsA(isA<Exception>()),
    );
  });
}