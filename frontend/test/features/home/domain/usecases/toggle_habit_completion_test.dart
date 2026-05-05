import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/home/domain/repositories/home_repository.dart';
import 'package:habitly/features/home/domain/usecases/toggle_habit_completion.dart';

import 'toggle_habit_completion_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late ToggleHabitCompletion useCase;
  late MockHomeRepository mockRepository;

  const testHabitId = 'habit-123';
  const testUserId = 'user-456';
  final testDay = DateTime(2026, 5, 24);

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = ToggleHabitCompletion(mockRepository);
  });

  test('should call repository.setHabitCompletedForDay with correct parameters (completed = true)', () async {
    when(mockRepository.setHabitCompletedForDay(
      habitId: testHabitId,
      userId: testUserId,
      day: testDay,
      completed: true,
    )).thenAnswer((_) async => {});

    await useCase(
      habitId: testHabitId,
      userId: testUserId,
      day: testDay,
      completed: true,
    );

    verify(mockRepository.setHabitCompletedForDay(
      habitId: testHabitId,
      userId: testUserId,
      day: testDay,
      completed: true,
    )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository.setHabitCompletedForDay with correct parameters (completed = false)', () async {
    when(mockRepository.setHabitCompletedForDay(
      habitId: testHabitId,
      userId: testUserId,
      day: testDay,
      completed: false,
    )).thenAnswer((_) async => {});

    await useCase(
      habitId: testHabitId,
      userId: testUserId,
      day: testDay,
      completed: false,
    );

    verify(mockRepository.setHabitCompletedForDay(
      habitId: testHabitId,
      userId: testUserId,
      day: testDay,
      completed: false,
    )).called(1);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.setHabitCompletedForDay(
      habitId: testHabitId,
      userId: testUserId,
      day: testDay,
      completed: true,
    )).thenThrow(Exception('Network error'));

    expect(
      () => useCase(
        habitId: testHabitId,
        userId: testUserId,
        day: testDay,
        completed: true,
      ),
      throwsA(isA<Exception>()),
    );
  });
}