import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group_achievement.dart';
import '../repositories/gamification_repository.dart';

class GetGroupAchievements {
  const GetGroupAchievements(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, List<GroupAchievement>>> call(String groupId) async {
    return await repository.getGroupAchievements(groupId);
  }
}
