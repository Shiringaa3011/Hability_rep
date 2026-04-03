import '../repositories/group_repository.dart';

class RemoveMember {
  final GroupRepository _repository;

  RemoveMember(this._repository);

  Future<void> call(String groupId, String memberId) =>
      _repository.removeMember(groupId, memberId);
}
