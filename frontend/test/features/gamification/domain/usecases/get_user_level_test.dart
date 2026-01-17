import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/error/failures.dart';
import 'package:habitly/features/gamification/domain/entities/user_level.dart';
import 'package:habitly/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:habitly/features/gamification/domain/usecases/get_user_level.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_user_level_test.mocks.dart';

@GenerateMocks([GamificationRepository])
void main() {
  late GetUserLevel usecase;
  late MockGamificationRepository mockRepository;

  setUp(() {
    mockRepository = MockGamificationRepository();
    usecase = GetUserLevel(mockRepository);
  });

  const tUserId = 'test-user-id';
  const tUserLevel = UserLevel(
    userId: tUserId,
    level: 5,
    totalPoints: 2500,
    pointsToNextLevel: 1100,
    progressPercent: 69.4,
  );

  test('should get user level from repository', () async {
    when(mockRepository.getUserLevel(any))
        .thenAnswer((_) async => const Right(tUserLevel));

    final result = await usecase(tUserId);

    expect(result, const Right(tUserLevel));
    verify(mockRepository.getUserLevel(tUserId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository fails', () async {
    when(mockRepository.getUserLevel(any))
        .thenAnswer((_) async => const Left(ServerFailure('Server error')));

    final result = await usecase(tUserId);

    expect(result, const Left(ServerFailure('Server error')));
    verify(mockRepository.getUserLevel(tUserId));
    verifyNoMoreInteractions(mockRepository);
  });
}
