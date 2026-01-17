import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/error/failures.dart';
import 'package:habitly/features/gamification/domain/entities/user_level.dart';
import 'package:habitly/features/gamification/domain/usecases/get_user_level.dart';
import 'package:habitly/features/gamification/presentation/bloc/level/level_bloc.dart';
import 'package:habitly/features/gamification/presentation/bloc/level/level_event.dart';
import 'package:habitly/features/gamification/presentation/bloc/level/level_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'level_bloc_test.mocks.dart';

@GenerateMocks([GetUserLevel])
void main() {
  late LevelBloc bloc;
  late MockGetUserLevel mockGetUserLevel;

  setUp(() {
    mockGetUserLevel = MockGetUserLevel();
    bloc = LevelBloc(getUserLevel: mockGetUserLevel);
  });

  tearDown(() {
    bloc.close();
  });

  const tUserId = 'test-user-id';
  const tUserLevel = UserLevel(
    userId: tUserId,
    level: 5,
    totalPoints: 2500,
    pointsToNextLevel: 1100,
    progressPercent: 69.4,
  );

  test('initial state should be LevelInitial', () {
    expect(bloc.state, equals(const LevelInitial()));
  });

  group('LoadLevel', () {
    blocTest<LevelBloc, LevelState>(
      'should emit [LevelLoading, LevelLoaded] when data is gotten successfully',
      build: () {
        when(mockGetUserLevel(any))
            .thenAnswer((_) async => const Right(tUserLevel));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadLevel(tUserId)),
      expect: () => [
        const LevelLoading(),
        const LevelLoaded(tUserLevel),
      ],
      verify: (_) {
        verify(mockGetUserLevel(tUserId));
      },
    );

    blocTest<LevelBloc, LevelState>(
      'should emit [LevelLoading, LevelError] when getting data fails',
      build: () {
        when(mockGetUserLevel(any))
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadLevel(tUserId)),
      expect: () => [
        const LevelLoading(),
        const LevelError('Server error'),
      ],
      verify: (_) {
        verify(mockGetUserLevel(tUserId));
      },
    );
  });

  group('RefreshLevel', () {
    blocTest<LevelBloc, LevelState>(
      'should emit LevelLoaded when refresh is successful',
      build: () {
        when(mockGetUserLevel(any))
            .thenAnswer((_) async => const Right(tUserLevel));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshLevel(tUserId)),
      expect: () => [
        const LevelLoaded(tUserLevel),
      ],
      verify: (_) {
        verify(mockGetUserLevel(tUserId));
      },
    );
  });
}
