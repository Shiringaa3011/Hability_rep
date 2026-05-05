import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/group_member_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/entities/group_invite_entity.dart';
import '../datasources/group_local_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl({
    required this.dio,
    required this.localDataSource,
  });

  final Dio dio;
  final GroupLocalDataSource localDataSource;

  List<GroupEntity> _mapGroups(List<dynamic> rows) {
    return rows.map((e) {
      final m = e as Map<String, dynamic>;
      return GroupEntity(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String?,
        createdBy: m['created_by'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        isActive: m['is_active'] as bool? ?? true,
        habitsCount: m['habits_count'] as int? ?? 0,
      );
    }).toList();
  }

  Future<void> _refreshGroupsCache(String userId) async {
    try {
      final response = await dio.get('${ApiConstants.groupsPath}/user/$userId');
      final groups = _mapGroups(response.data as List<dynamic>);
      await localDataSource.cacheGroups(userId, groups);
    } catch (_) {}
  }

  @override
  Future<List<GroupEntity>> getUserGroups(String userId) async {
    final cached = localDataSource.getCachedGroups(userId);

    if (cached != null) {
      _refreshGroupsCache(userId).ignore();
      return cached;
    }

    try {
      final response = await dio.get('${ApiConstants.groupsPath}/user/$userId');
      final groups = _mapGroups(response.data as List<dynamic>);
      await localDataSource.cacheGroups(userId, groups);
      return groups;
    } catch (e) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<GroupDetail> getGroupDetails(String groupId, String currentUserId) async {
    final response = await dio.get(
      '${ApiConstants.groupsPath}/$groupId',
      queryParameters: {'current_user_id': currentUserId},
    );
    final data = response.data as Map<String, dynamic>;
    final groupData = data['group'] as Map<String, dynamic>;
    final group = GroupEntity(
      id: groupData['id'] as String,
      name: groupData['name'] as String,
      description: groupData['description'] as String?,
      createdBy: groupData['created_by'] as String,
      createdAt: DateTime.parse(groupData['created_at'] as String),
      isActive: groupData['is_active'] as bool? ?? true,
    );
    final members = (data['members'] as List<dynamic>).map((raw) {
      final m = raw as Map<String, dynamic>;
      return GroupMemberEntity(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        username: m['username'] as String,
        points: m['points'] as int? ?? 0,
        reactions: m['reactions'] as int? ?? 0,
        currentUserReacted: m['current_user_reacted'] as bool? ?? false,
        joinedAt: DateTime.parse(m['joined_at'] as String),
      );
    }).toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    return GroupDetail(
      group: group,
      members: members,
      groupAchievements: (data['group_achievements'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    await dio.post(
      '${ApiConstants.groupsPath}/$groupId/leave',
      queryParameters: {'user_id': userId},
    );
    await localDataSource.invalidateGroups(userId);
  }

  @override
  Future<void> removeMember(String groupId, String memberId) async {
    await dio.delete('${ApiConstants.groupsPath}/$groupId/members/$memberId');
  }

  @override
  Future<void> sendReaction(
    String groupId,
    String fromUserId,
    String toUserId,
  ) async {
    await dio.post(
      '${ApiConstants.groupsPath}/$groupId/reaction',
      queryParameters: {
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
      },
    );
  }

  @override
  Future<GroupEntity> createGroup({
    required String creatorUserId,
    required String name,
    String? description,
  }) async {
    final response = await dio.post(
      ApiConstants.groupsPath,
      data: {
        'user_id': creatorUserId,
        'name': name,
        'description': description,
      },
    );
    final m = response.data as Map<String, dynamic>;

    await localDataSource.invalidateGroups(creatorUserId);

    return GroupEntity(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String?,
      createdBy: m['created_by'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      isActive: m['is_active'] as bool? ?? true,
    );
  }

  @override
  Future<void> inviteUser({
    required String groupId,
    required String fromUserId,
    required String toUsername,
  }) async {
    await dio.post(
      '${ApiConstants.groupsPath}/invites',
      data: {
        'group_id': groupId,
        'from_user_id': fromUserId,
        'to_username': toUsername,
      },
    );
  }

  @override
  Future<List<GroupInviteEntity>> getPendingInvites(String userId) async {
    final response = await dio.get(
      '${ApiConstants.groupsPath}/invites/pending/$userId',
    );
    final rows = response.data as List<dynamic>;
    return rows.map((raw) {
      final m = raw as Map<String, dynamic>;
      return GroupInviteEntity(
        id: m['id'] as String,
        groupId: m['group_id'] as String,
        groupName: m['group_name'] as String,
        fromUserId: m['from_user_id'] as String,
        fromUsername: m['from_username'] as String,
        toUserId: m['to_user_id'] as String,
        status: m['status'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> decideInvite({
    required String inviteId,
    required String userId,
    required bool accept,
  }) async {
    await dio.post(
      '${ApiConstants.groupsPath}/invites/$inviteId/decision',
      data: {
        'user_id': userId,
        'accept': accept,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final response = await dio.get(
      '/users/search',
      queryParameters: {'q': query},
    );
    return (response.data as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<void> deleteGroup(String groupId, String userId) async {
    await dio.delete(
      '${ApiConstants.groupsPath}/$groupId',
      queryParameters: {'user_id': userId},
    );
    await localDataSource.invalidateGroups(userId);
  }
}
