import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/achievement.dart';
import '../entities/habit_stats.dart';
import '../entities/user_level.dart';
import '../entities/user_stats.dart';

abstract class GamificationRepository {
  Future<Either<Failure, UserLevel>> getUserLevel(String userId);

  Future<Either<Failure, UserStats>> getUserStats(String userId, StatsPeriod period);

  Future<Either<Failure, List<HabitStats>>> getUserHabitsStats(
    String userId,
    StatsPeriod period,
  );

  Future<Either<Failure, List<Achievement>>> getAchievements(String userId);

  Future<Either<Failure, void>> completeHabit(String habitId, String userId);

  Future<Either<Failure, void>> refreshData(String userId);
}
