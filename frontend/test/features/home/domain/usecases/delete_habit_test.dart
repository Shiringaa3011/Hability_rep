import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/home/domain/repositories/home_repository.dart';
import 'package:habitly/features/home/domain/usecases/delete_habit.dart';

import 'delete_habit_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late DeleteHabitUseCase useCase;
  late MockHomeRepository mockRepository;

  const testHabitId = 'habit-123';
  const testUserId = 'user-456';

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = DeleteHabitUseCase(mockRepository);
  });

  test('should call repository.deleteHabit with correct parameters', () async {
    when(mockRepository.deleteHabit(testHabitId, testUserId))
        .thenAnswer((_) async => {});

    await useCase(testHabitId, testUserId);

    verify(mockRepository.deleteHabit(testHabitId, testUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.deleteHabit(testHabitId, testUserId))
        .thenThrow(Exception('Network error'));

    expect(
      () => useCase(testHabitId, testUserId),
      throwsA(isA<Exception>()),
    );
  });
}