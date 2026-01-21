import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/habit_stats.dart';
import '../../domain/entities/user_level.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_local_datasource.dart';
import '../datasources/gamification_remote_datasource.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  GamificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final GamificationRemoteDataSource remoteDataSource;
  final GamificationLocalDataSource localDataSource;

  @override
  Future<Either<Failure, UserLevel>> getUserLevel(String userId) async {
    try {
      final cachedLevel = await localDataSource.getCachedUserLevel(userId);
      
      try {
        final remoteLevel = await remoteDataSource.getUserLevel(userId);
        await localDataSource.cacheUserLevel(remoteLevel);
        return Right(remoteLevel.toEntity());
      } catch (e) {
        if (cachedLevel != null) {
          return Right(cachedLevel.toEntity());
        }
        rethrow;
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserStats>> getUserStats(
    String userId,
    StatsPeriod period,
  ) async {
    try {
      final cachedStats = await localDataSource.getCachedUserStats(userId, period);
      
      try {
        final remoteStats = await remoteDataSource.getUserStats(userId, period);
        await localDataSource.cacheUserStats(remoteStats);
        return Right(remoteStats.toEntity());
      } catch (e) {
        if (cachedStats != null) {
          return Right(cachedStats.toEntity());
        }
        rethrow;
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HabitStats>>> getUserHabitsStats(
    String userId,
    StatsPeriod period,
  ) async {
    try {
      final remoteStats = await remoteDataSource.getUserHabitsStats(userId, period);
      return Right(remoteStats.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getAchievements(String userId) async {
    try {
      final cachedAchievements = await localDataSource.getCachedAchievements(userId);
      
      try {
        final remoteAchievements = await remoteDataSource.getAchievements(userId);
        await localDataSource.cacheAchievements(userId, remoteAchievements);
        return Right(remoteAchievements.map((model) => model.toEntity()).toList());
      } catch (e) {
        if (cachedAchievements != null) {
          return Right(cachedAchievements.map((model) => model.toEntity()).toList());
        }
        rethrow;
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> completeHabit(String habitId, String userId) async {
    try {
      await remoteDataSource.completeHabit(habitId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshData(String userId) async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to refresh data: $e'));
    }
  }
}
