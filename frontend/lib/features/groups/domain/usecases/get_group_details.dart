import '../repositories/group_repository.dart';

class GetGroupDetails {
  final GroupRepository _repository;

  GetGroupDetails(this._repository);

  Future<GroupDetail> call(String groupId, String currentUserId) =>
      _repository.getGroupDetails(groupId, currentUserId);
}
