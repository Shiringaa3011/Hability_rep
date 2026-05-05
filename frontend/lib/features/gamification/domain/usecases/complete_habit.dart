import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/achievement.dart';
import '../repositories/gamification_repository.dart';

class CompleteHabitParams {
  const CompleteHabitParams({
    required this.habitId,
    required this.userId,
    required this.completionDate,
  });

  final String habitId;
  final String userId;
  final DateTime completionDate;
}

class CompleteHabit {
  const CompleteHabit(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, List<NewAchievementInfo>>> call(
    CompleteHabitParams params,
  ) async {
    return repository.completeHabit(
      params.habitId,
      params.userId,
      params.completionDate,
    );
  }
}
