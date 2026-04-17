import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group_stats.dart';
import '../entities/user_stats.dart';
import '../repositories/gamification_repository.dart';

class GetGroupStatsParams {
  const GetGroupStatsParams({
    required this.groupId,
    required this.period,
  });

  final String groupId;
  final StatsPeriod period;
}

class GetGroupStats {
  const GetGroupStats(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, GroupStats>> call(GetGroupStatsParams params) async {
    return await repository.getGroupStats(params.groupId, params.period);
  }
}
