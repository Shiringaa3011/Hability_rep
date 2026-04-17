import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/group_achievement.dart';
import '../../domain/entities/group_stats.dart';
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
  Future<Either<Failure, List<NewAchievementInfo>>> completeHabit(
    String habitId,
    String userId,
  ) async {
    try {
      final newAchievements = await remoteDataSource.completeHabit(habitId, userId);
      return Right(newAchievements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GroupAchievement>>> getGroupAchievements(
    String groupId,
  ) async {
    try {
      final raw = await remoteDataSource.getGroupAchievements(groupId);
      final achievements = raw.map((m) {
        final typeStr = m['type'] as String;
        final type = GroupAchievementType.values.firstWhere(
          (t) => t.name == _snakeToCamel(typeStr),
          orElse: () => GroupAchievementType.groupTotalHabits,
        );
        return GroupAchievement(
          id: m['id'] as String,
          name: m['name'] as String,
          description: m['description'] as String,
          icon: m['icon'] as String,
          type: type,
          conditionValue: m['condition_value'] as int,
          rewardPoints: m['reward_points'] as int,
          isEarned: m['is_earned'] as bool,
          progress: m['progress'] as int,
          progressPercent: (m['progress_percent'] as num).toDouble(),
        );
      }).toList();
      return Right(achievements);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, GroupStats>> getGroupStats(
    String groupId,
    StatsPeriod period,
  ) async {
    try {
      final cached = await localDataSource.getCachedGroupStats(groupId, period);

      try {
        final remote = await remoteDataSource.getGroupStats(groupId, period);
        await localDataSource.cacheGroupStats(remote);
        return Right(remote.toEntity());
      } catch (e) {
        if (cached != null) {
          return Right(cached.toEntity());
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

  static String _snakeToCamel(String snake) {
    final parts = snake.split('_');
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
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
