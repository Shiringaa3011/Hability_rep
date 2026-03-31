import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class GetUserGroups {
  final GroupRepository _repository;

  GetUserGroups(this._repository);

  Future<List<GroupEntity>> call(String userId) =>
      _repository.getUserGroups(userId);
}
