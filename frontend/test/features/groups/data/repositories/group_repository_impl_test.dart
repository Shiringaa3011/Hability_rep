import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:habitly/features/groups/data/datasources/group_local_datasource.dart';
import 'package:habitly/features/groups/data/repositories/group_repository_impl.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/domain/entities/group_member_entity.dart';
import 'package:habitly/features/groups/domain/entities/group_invite_entity.dart';

import 'group_repository_impl_test.mocks.dart';

@GenerateMocks([Dio, GroupLocalDataSource])
void main() {
  late GroupRepositoryImpl repository;
  late MockDio mockDio;
  late MockGroupLocalDataSource mockLocalDataSource;

  const testUserId = 'user-123';
  const testGroupId = 'group-456';
  const testInviteId = 'invite-789';

  setUp(() {
    mockDio = MockDio();
    mockLocalDataSource = MockGroupLocalDataSource();
    repository = GroupRepositoryImpl(
      dio: mockDio,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getUserGroups', () {
    final testGroups = [
      {
        'id': 'group-1',
        'name': 'Test Group 1',
        'description': 'Description 1',
        'created_by': 'user-123',
        'created_at': '2026-01-01T10:00:00Z',
        'is_active': true,
        'habits_count': 3,
      },
      {
        'id': 'group-2',
        'name': 'Test Group 2',
        'description': null,
        'created_by': 'user-456',
        'created_at': '2026-01-02T10:00:00Z',
        'is_active': true,
        'habits_count': 1,
      },
    ];

    final expectedGroups = [
      GroupEntity(
        id: 'group-1',
        name: 'Test Group 1',
        description: 'Description 1',
        createdBy: 'user-123',
        createdAt: DateTime.parse('2026-01-01T10:00:00Z'),
        isActive: true,
        habitsCount: 3,
      ),
      GroupEntity(
        id: 'group-2',
        name: 'Test Group 2',
        description: null,
        createdBy: 'user-456',
        createdAt: DateTime.parse('2026-01-02T10:00:00Z'),
        isActive: true,
        habitsCount: 1,
      ),
    ];

    test('should return cached groups when available', () async {
      when(mockLocalDataSource.getCachedGroups(testUserId))
          .thenReturn(expectedGroups);

      final result = await repository.getUserGroups(testUserId);

      expect(result, equals(expectedGroups));
      verify(mockLocalDataSource.getCachedGroups(testUserId)).called(1);
    });

    test('should fetch from network when cache is empty', () async {
      when(mockLocalDataSource.getCachedGroups(testUserId))
          .thenReturn(null);
      when(mockDio.get(any)).thenAnswer(
        (_) async => Response(
          data: testGroups,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/groups/user/$testUserId'),
        ),
      );
      when(mockLocalDataSource.cacheGroups(testUserId, any))
          .thenAnswer((_) async {});

      final result = await repository.getUserGroups(testUserId);

      expect(result.length, equals(2));
      expect(result[0].id, equals('group-1'));
      expect(result[0].name, equals('Test Group 1'));
      verify(mockDio.get(any)).called(1);
      verify(mockLocalDataSource.cacheGroups(testUserId, any)).called(1);
    });

    test('should return cached groups when network fails and cache exists', () async {
      when(mockLocalDataSource.getCachedGroups(testUserId))
          .thenReturn(expectedGroups);
      when(mockDio.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/groups/user/$testUserId'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.getUserGroups(testUserId);

      expect(result, equals(expectedGroups));
    });

    test('should rethrow when network fails and cache is empty', () async {
      when(mockLocalDataSource.getCachedGroups(testUserId))
          .thenReturn(null);
      when(mockDio.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/groups/user/$testUserId'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repository.getUserGroups(testUserId),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('getGroupDetails', () {
    const currentUserId = 'user-123';
    final testResponse = {
      'group': {
        'id': testGroupId,
        'name': 'Cool Group',
        'description': 'Group for cool people',
        'created_by': 'user-456',
        'created_at': '2026-01-01T10:00:00Z',
        'is_active': true,
      },
      'members': [
        {
          'id': 'member-1',
          'user_id': 'user-456',
          'username': 'alice',
          'points': 1500,
          'reactions': 5,
          'current_user_reacted': false,
          'joined_at': '2026-01-01T10:00:00Z',
        },
        {
          'id': 'member-2',
          'user_id': currentUserId,
          'username': 'bob',
          'points': 800,
          'reactions': 2,
          'current_user_reacted': true,
          'joined_at': '2026-01-02T10:00:00Z',
        },
      ],
      'group_achievements': ['First Step', 'Team Work'],
    };

    test('should return group details with members sorted by points', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: testResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/groups/$testGroupId'),
        ),
      );

      final result = await repository.getGroupDetails(testGroupId, currentUserId);

      expect(result.group.id, equals(testGroupId));
      expect(result.group.name, equals('Cool Group'));
      expect(result.members.length, equals(2));
      expect(result.members[0].userId, equals('user-456'));
      expect(result.members[1].userId, equals(currentUserId));
      expect(result.groupAchievements.length, equals(2));
      expect(result.groupAchievements[0], equals('First Step'));
    });

    test('should handle empty group achievements', () async {
      final responseWithoutAchievements = {
        ...testResponse,
        'group_achievements': null,
      };
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: responseWithoutAchievements,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/groups/$testGroupId'),
        ),
      );

      final result = await repository.getGroupDetails(testGroupId, currentUserId);

      expect(result.groupAchievements, isEmpty);
    });
  });

  group('leaveGroup', () {
    test('should send POST request and invalidate cache', () async {
      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/groups/$testGroupId/leave'),
        ),
      );
      when(mockLocalDataSource.invalidateGroups(testUserId))
          .thenAnswer((_) async {});

      await repository.leaveGroup(testGroupId, testUserId);

      verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
      verify(mockLocalDataSource.invalidateGroups(testUserId)).called(1);
    });
  });

  group('removeMember', () {
    const memberId = 'member-123';

    test('should send DELETE request', () async {
      when(mockDio.delete(any)).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/groups/$testGroupId/members/$memberId',
          ),
        ),
      );

      await repository.removeMember(testGroupId, memberId);

      verify(mockDio.delete(any)).called(1);
    });
  });

  group('sendReaction', () {
    const fromUserId = 'user-123';
    const toUserId = 'user-456';

    test('should send POST request with correct parameters', () async {
      when(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/groups/$testGroupId/reaction'),
        ),
      );

      await repository.sendReaction(testGroupId, fromUserId, toUserId);

      verify(mockDio.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });
  });

  group('createGroup', () {
    const groupName = 'New Group';
    const groupDescription = 'Description';
    final createdGroupResponse = {
      'id': 'new-group-123',
      'name': groupName,
      'description': groupDescription,
      'created_by': testUserId,
      'created_at': '2026-01-10T10:00:00Z',
      'is_active': true,
    };

    test('should send POST request and return created group', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: createdGroupResponse,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/groups'),
        ),
      );
      when(mockLocalDataSource.invalidateGroups(testUserId))
          .thenAnswer((_) async {});

      final result = await repository.createGroup(
        creatorUserId: testUserId,
        name: groupName,
        description: groupDescription,
      );

      expect(result.id, equals('new-group-123'));
      expect(result.name, equals(groupName));
      expect(result.description, equals(groupDescription));
      expect(result.createdBy, equals(testUserId));
      verify(mockLocalDataSource.invalidateGroups(testUserId)).called(1);
    });

    test('should create group without description', () async {
      final responseWithoutDescription = {
        ...createdGroupResponse,
        'description': null,
      };
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: responseWithoutDescription,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/groups'),
        ),
      );
      when(mockLocalDataSource.invalidateGroups(testUserId))
          .thenAnswer((_) async {});

      final result = await repository.createGroup(
        creatorUserId: testUserId,
        name: groupName,
        description: null,
      );

      expect(result.description, isNull);
    });
  });

  group('inviteUser', () {
    const fromUserId = 'user-123';
    const toUsername = 'invited_user';

    test('should send POST request with correct data', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/groups/invites'),
        ),
      );

      await repository.inviteUser(
        groupId: testGroupId,
        fromUserId: fromUserId,
        toUsername: toUsername,
      );

      verify(mockDio.post(any, data: anyNamed('data'))).called(1);
    });
  });

  group('getPendingInvites', () {
    final testInvites = [
      {
        'id': 'invite-1',
        'group_id': 'group-1',
        'group_name': 'Cool Group',
        'from_user_id': 'user-456',
        'from_username': 'alice',
        'to_user_id': testUserId,
        'status': 'pending',
        'created_at': '2026-01-01T10:00:00Z',
      },
      {
        'id': 'invite-2',
        'group_id': 'group-2',
        'group_name': 'Dev Team',
        'from_user_id': 'user-789',
        'from_username': 'charlie',
        'to_user_id': testUserId,
        'status': 'pending',
        'created_at': '2026-01-02T10:00:00Z',
      },
    ];

    test('should return list of pending invites', () async {
      when(mockDio.get(any)).thenAnswer(
        (_) async => Response(
          data: testInvites,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/groups/invites/pending/$testUserId',
          ),
        ),
      );

      final result = await repository.getPendingInvites(testUserId);

      expect(result.length, equals(2));
      expect(result[0].id, equals('invite-1'));
      expect(result[0].groupName, equals('Cool Group'));
      expect(result[0].fromUsername, equals('alice'));
      expect(result[0].status, equals('pending'));
      expect(result[1].id, equals('invite-2'));
    });

    test('should return empty list when no invites', () async {
      when(mockDio.get(any)).thenAnswer(
        (_) async => Response(
          data: [],
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/groups/invites/pending/$testUserId',
          ),
        ),
      );

      final result = await repository.getPendingInvites(testUserId);

      expect(result, isEmpty);
    });
  });

  group('decideInvite', () {
    test('should send POST request with accept = true', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/groups/invites/$testInviteId/decision',
          ),
        ),
      );

      await repository.decideInvite(
        inviteId: testInviteId,
        userId: testUserId,
        accept: true,
      );

      verify(mockDio.post(any, data: anyNamed('data'))).called(1);
    });

    test('should send POST request with accept = false', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/groups/invites/$testInviteId/decision',
          ),
        ),
      );

      await repository.decideInvite(
        inviteId: testInviteId,
        userId: testUserId,
        accept: false,
      );

      verify(mockDio.post(any, data: anyNamed('data'))).called(1);
    });
  });

  group('searchUsers', () {
    const query = 'ali';
    final testUsers = [
      {'id': 'user-1', 'username': 'alice'},
      {'id': 'user-2', 'username': 'alex'},
    ];

    test('should return list of users matching query', () async {
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: testUsers,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users/search'),
        ),
      );

      final result = await repository.searchUsers(query);

      expect(result.length, equals(2));
      expect(result[0]['username'], equals('alice'));
      expect(result[1]['username'], equals('alex'));
    });
  });

  group('deleteGroup', () {
    test('should send DELETE request and invalidate cache', () async {
      when(mockDio.delete(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/groups/$testGroupId'),
        ),
      );
      when(mockLocalDataSource.invalidateGroups(testUserId))
          .thenAnswer((_) async {});

      await repository.deleteGroup(testGroupId, testUserId);

      verify(mockDio.delete(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
      verify(mockLocalDataSource.invalidateGroups(testUserId)).called(1);
    });
  });
}