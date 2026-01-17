import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/achievement.dart';
import '../repositories/gamification_repository.dart';

class GetAchievements {
  const GetAchievements(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, List<Achievement>>> call(String userId) async {
    return await repository.getAchievements(userId);
  }
}
