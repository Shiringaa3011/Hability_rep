import '../repositories/group_repository.dart';

class SendReaction {
  final GroupRepository _repository;

  SendReaction(this._repository);

  Future<void> call({
    required String groupId,
    required String fromUserId,
    required String toUserId,
  }) =>
      _repository.sendReaction(groupId, fromUserId, toUserId);
}
