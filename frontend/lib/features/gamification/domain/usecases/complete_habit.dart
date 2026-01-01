import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/gamification_repository.dart';

class CompleteHabitParams {
  const CompleteHabitParams({
    required this.habitId,
    required this.userId,
  });

  final String habitId;
  final String userId;
}

class CompleteHabit {
  const CompleteHabit(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, void>> call(CompleteHabitParams params) async {
    return await repository.completeHabit(params.habitId, params.userId);
  }
}
