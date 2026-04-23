// при подключении api добавить метод в контракт и реализацию
class JoinGroup {
  const JoinGroup();

  Future<void> call(String groupId, String userId) async {
    // mock: POST /groups/{id}/join
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
