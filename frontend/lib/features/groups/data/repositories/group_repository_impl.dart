import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/repositories/group_repository.dart';

// заменить на Dio + DTO + маппинг, когда будет готов backend.
class GroupRepositoryImpl implements GroupRepository {
  final List<GroupEntity> _mockGroups = [
    GroupEntity(
      id: '1',
      name: 'Семья',
      description: 'Наши семейные привычки',
      createdBy: '00000000-0000-0000-0000-000000000001',
      createdAt: DateTime(2025, 11, 1),
    ),
    GroupEntity(
      id: '2',
      name: 'Друзья',
      description: 'Вместе к здоровью',
      createdBy: 'user_2',
      createdAt: DateTime(2025, 11, 10),
    ),
  ];

  //mock
  final Map<String, List<GroupMemberEntity>> _mockMembers = {
    '1': [
      GroupMemberEntity(
        id: 'm1',
        userId: '00000000-0000-0000-0000-000000000001',
        username: 'Вы',
        points: 450,
        reactions: 3,
        joinedAt: DateTime(2025, 11, 2),
      ),
      GroupMemberEntity(
        id: 'm2',
        userId: 'user_2',
        username: 'Пётр',
        points: 320,
        reactions: 0,
        joinedAt: DateTime(2025, 11, 3),
      ),
      GroupMemberEntity(
        id: 'm3',
        userId: 'user_3',
        username: 'Мария',
        points: 280,
        reactions: 0,
        joinedAt: DateTime(2025, 11, 4),
      ),
    ],
    '2': [
      GroupMemberEntity(
        id: 'm4',
        userId: '00000000-0000-0000-0000-000000000001',
        username: 'Вы',
        points: 120,
        reactions: 0,
        joinedAt: DateTime(2025, 11, 11),
      ),
      GroupMemberEntity(
        id: 'm5',
        userId: 'user_2',
        username: 'Пётр',
        points: 380,
        reactions: 5,
        joinedAt: DateTime(2025, 11, 11),
      ),
    ],
  };

  final Map<String, List<String>> _achievementsByGroup = {
    '1': ['Серия 7 дней', 'Командная цель: вода'],
    '2': ['Первый общий квест', 'Топ недели'],
  };

  @override
  Future<List<GroupEntity>> getUserGroups(String userId) async {
    // mock: GET /users/{id}/groups
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _mockGroups.where((g) {
      final members = _mockMembers[g.id] ?? [];
      return members.any((m) => m.userId == userId);
    }).toList();
  }

  @override
  Future<GroupDetail> getGroupDetails(String groupId, String currentUserId) async {
    // mock: GET /groups/{id}
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final group = _mockGroups.firstWhere((g) => g.id == groupId);
    final members = List<GroupMemberEntity>.from(_mockMembers[groupId] ?? [])
      ..sort((a, b) => b.points.compareTo(a.points));
    return GroupDetail(
      group: group,
      members: members,
      groupAchievements: List<String>.from(_achievementsByGroup[groupId] ?? const []),
    );
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    // mock: POST /groups/{id}/leave
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final list = _mockMembers[groupId];
    if (list == null) return;
    list.removeWhere((m) => m.userId == userId);
  }

  @override
  Future<void> removeMember(String groupId, String memberId) async {
    // mock: DELETE /groups/{id}/members/{memberId}
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final list = _mockMembers[groupId];
    if (list == null) return;
    list.removeWhere((m) => m.id == memberId || m.userId == memberId);
  }

  @override
  Future<void> sendReaction(
    String groupId,
    String fromUserId,
    String toUserId,
  ) async {
    // mock: POST /groups/{id}/reactions
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final list = _mockMembers[groupId];
    if (list == null || list.isEmpty) return;
    final sorted = List<GroupMemberEntity>.from(list)
      ..sort((a, b) => b.points.compareTo(a.points));
    final leader = sorted.first;
    if (leader.userId != toUserId) return;
    final idx = list.indexWhere((m) => m.userId == toUserId);
    if (idx == -1) return;
    final m = list[idx];
    list[idx] = GroupMemberEntity(
      id: m.id,
      userId: m.userId,
      username: m.username,
      points: m.points,
      reactions: m.reactions + 1,
      joinedAt: m.joinedAt,
    );
  }

  @override
  Future<GroupEntity> createGroup({
    required String creatorUserId,
    required String name,
    String? description,
  }) async {
    // mock: POST /groups
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final id = 'g_${DateTime.now().millisecondsSinceEpoch}';
    final trimmedDesc = description?.trim();
    final entity = GroupEntity(
      id: id,
      name: name.trim(),
      description: (trimmedDesc == null || trimmedDesc.isEmpty) ? null : trimmedDesc,
      createdBy: creatorUserId,
      createdAt: DateTime.now(),
    );
    _mockGroups.add(entity);
    _mockMembers[id] = [
      GroupMemberEntity(
        id: 'mem_${id}_creator',
        userId: creatorUserId,
        username: 'Вы',
        points: 0,
        reactions: 0,
        joinedAt: DateTime.now(),
      ),
    ];
    _achievementsByGroup[id] = [];
    return entity;
  }
}
