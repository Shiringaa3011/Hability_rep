import '../entities/group_entity.dart';
import '../repositories/group_repository.dart';

class CreateGroup {
  final GroupRepository _repository;

  CreateGroup(this._repository);

  Future<GroupEntity> call({
    required String creatorUserId,
    required String name,
    String? description,
  }) =>
      _repository.createGroup(
        creatorUserId: creatorUserId,
        name: name,
        description: description,
      );
}
