import '../repositories/home_repository.dart';

class GetHomeGroupFilterOptions {
  final HomeRepository _repository;

  GetHomeGroupFilterOptions(this._repository);

  Future<List<HomeGroupFilterOption>> call(String userId) =>
      _repository.getGroupFilterOptions(userId);
}
