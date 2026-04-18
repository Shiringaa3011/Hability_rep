import '../repositories/home_repository.dart';

class DeleteHabitUseCase {
  final HomeRepository _repository;

  DeleteHabitUseCase(this._repository);

  Future<void> call(String habitId, String userId) async {
    await _repository.deleteHabit(habitId, userId);
  }
}