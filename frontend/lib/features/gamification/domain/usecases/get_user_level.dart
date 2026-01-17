import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_level.dart';
import '../repositories/gamification_repository.dart';

class GetUserLevel {
  const GetUserLevel(this.repository);

  final GamificationRepository repository;

  Future<Either<Failure, UserLevel>> call(String userId) async {
    return await repository.getUserLevel(userId);
  }
}
