import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_stats.dart';
import '../repositories/gamification_repository.dart';

class GetUserStatsParams {
  const GetUserStatsParams({
    required this.userId,
    required this.period,
  });

  final String userId;
  final StatsPeriod period;
}

class GetUserStats {
  const GetUserStats(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, UserStats>> call(GetUserStatsParams params) async {
    return await repository.getUserStats(params.userId, params.period);
  }
}
