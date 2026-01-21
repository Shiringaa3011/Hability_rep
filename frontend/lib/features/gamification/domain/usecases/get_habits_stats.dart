import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/habit_stats.dart';
import '../entities/user_stats.dart';
import '../repositories/gamification_repository.dart';

class GetHabitsStatsParams {
  const GetHabitsStatsParams({
    required this.userId,
    required this.period,
  });

  final String userId;
  final StatsPeriod period;
}

class GetHabitsStats {
  const GetHabitsStats(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, List<HabitStats>>> call(GetHabitsStatsParams params) async {
    return await repository.getUserHabitsStats(params.userId, params.period);
  }
}
