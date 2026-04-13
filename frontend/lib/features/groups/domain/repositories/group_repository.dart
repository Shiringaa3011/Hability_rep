import '../entities/group_entity.dart';
import '../entities/group_member_entity.dart';

abstract class GroupRepository {
  Future<List<GroupEntity>> getUserGroups(String userId);
  
  Future<GroupDetail> getGroupDetails(String groupId, String currentUserId);
  
  Future<void> leaveGroup(String groupId, String userId);
  
  Future<void> removeMember(String groupId, String memberId);
  
  Future<void> sendReaction(String groupId, String fromUserId, String toUserId);

  Future<GroupEntity> createGroup({
    required String creatorUserId,
    required String name,
    String? description,
  });

  Future<void> inviteUser({
    required String groupId,
    required String fromUserId,
    required String toUsername,
  });

  Future<List<GroupInviteEntity>> getPendingInvites(String userId);

  Future<void> decideInvite({
    required String inviteId,
    required String userId,
    required bool accept,
  });
}

class GroupDetail {
  final GroupEntity group;
  final List<GroupMemberEntity> members;

  final List<String> groupAchievements;

  const GroupDetail({
    required this.group,
    required this.members,
    this.groupAchievements = const [],
  });

  int get totalGroupPoints =>
      members.fold<int>(0, (sum, m) => sum + m.points);

  GroupMemberEntity? get leader =>
      members.isEmpty ? null : members.first;

  int get leaderReactionCount => leader?.reactions ?? 0;
}

class GroupInviteEntity {
  final String id;
  final String groupId;
  final String groupName;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String status;
  final DateTime createdAt;

  const GroupInviteEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });
}