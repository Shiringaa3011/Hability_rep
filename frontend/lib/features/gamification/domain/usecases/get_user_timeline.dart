import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/timeline_point.dart';
import '../entities/user_stats.dart';
import '../repositories/gamification_repository.dart';

class GetUserTimelineParams {
  const GetUserTimelineParams({required this.userId, required this.period});

  final String userId;
  final StatsPeriod period;
}

class GetUserTimeline {
  const GetUserTimeline(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, List<TimelinePoint>>> call(
    GetUserTimelineParams params,
  ) async {
    return repository.getUserTimeline(params.userId, params.period);
  }
}
