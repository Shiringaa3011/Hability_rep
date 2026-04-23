import '../repositories/group_repository.dart';

class LeaveGroup {
  final GroupRepository _repository;

  LeaveGroup(this._repository);

  Future<void> call(String groupId, String userId) =>
      _repository.leaveGroup(groupId, userId);
}
