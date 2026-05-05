import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/domain/entities/group_member_entity.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/groups/domain/usecases/get_group_details.dart';
import 'package:habitly/features/groups/domain/usecases/leave_group.dart';
import 'package:habitly/features/groups/domain/usecases/remove_member.dart';
import 'package:habitly/features/groups/domain/usecases/send_reaction.dart';
import 'package:habitly/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:habitly/features/groups/presentation/bloc/group_detail_event.dart';
import 'package:habitly/features/groups/presentation/bloc/group_detail_state.dart';

import 'group_detail_bloc_test.mocks.dart';

@GenerateMocks([
  GetGroupDetails,
  LeaveGroup,
  RemoveMember,
  SendReaction,
  GroupRepository,
])
void main() {
  late GroupDetailBloc bloc;
  late MockGetGroupDetails mockGetGroupDetails;
  late MockLeaveGroup mockLeaveGroup;
  late MockRemoveMember mockRemoveMember;
  late MockSendReaction mockSendReaction;
  late MockGroupRepository mockRepository;

  const testGroupId = 'group-123';
  const testCurrentUserId = 'user-456';
  const testMemberId = 'member-789';

  final testGroup = GroupEntity(
    id: testGroupId,
    name: 'Тестовая группа',
    description: 'Описание группы',
    createdBy: 'user-456',
    createdAt: DateTime(2026, 1, 1),
    isActive: true,
    habitsCount: 3,
  );

  final testMembers = [
    GroupMemberEntity(
      id: 'm1',
      userId: 'user-456',
      username: 'Я',
      points: 100,
      reactions: 2,
      joinedAt: DateTime(2026, 1, 1),
    ),
    GroupMemberEntity(
      id: 'm2',
      userId: 'user-789',
      username: 'Друг',
      points: 50,
      reactions: 0,
      joinedAt: DateTime(2026, 1, 2),
    ),
  ];

  final testDetail = GroupDetail(
    group: testGroup,
    members: testMembers,
    groupAchievements: ['Первый шаг', 'Команда'],
  );

  final testDetailAfterReaction = GroupDetail(
    group: testGroup,
    members: [
      testMembers[0],
      GroupMemberEntity(
        id: testMembers[1].id,
        userId: testMembers[1].userId,
        username: testMembers[1].username,
        points: testMembers[1].points,
        reactions: 1,
        joinedAt: testMembers[1].joinedAt,
      ),
    ],
    groupAchievements: ['Первый шаг', 'Команда'],
  );

  setUp(() {
    mockGetGroupDetails = MockGetGroupDetails();
    mockLeaveGroup = MockLeaveGroup();
    mockRemoveMember = MockRemoveMember();
    mockSendReaction = MockSendReaction();
    mockRepository = MockGroupRepository();

    when(mockGetGroupDetails(any, any)).thenAnswer((_) async => testDetail);

    bloc = GroupDetailBloc(
      groupId: testGroupId,
      currentUserId: testCurrentUserId,
      getGroupDetails: mockGetGroupDetails,
      leaveGroup: mockLeaveGroup,
      removeMember: mockRemoveMember,
      sendReaction: mockSendReaction,
      repository: mockRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('Initial state', () {
    test('should have correct initial state', () {
      expect(bloc.state.groupId, equals(testGroupId));
      expect(bloc.state.currentUserId, equals(testCurrentUserId));
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.detail, isNull);
      expect(bloc.state.error, isNull);
      expect(bloc.state.successMessage, isNull);
    });
  });

  group('LoadGroupDetail', () {
    blocTest<GroupDetailBloc, GroupDetailState>(
      'should emit loading and loaded states on successful load',
      build: () {
        when(mockGetGroupDetails(testGroupId, testCurrentUserId))
            .thenAnswer((_) async => testDetail);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGroupDetail(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
      )),
      expect: () => [
        predicate<GroupDetailState>((state) =>
            state.isLoading == true && state.detail == null),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false &&
            state.detail == testDetail &&
            state.error == null),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should emit error on DioException',
      build: () {
        when(mockGetGroupDetails(testGroupId, testCurrentUserId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGroupDetail(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
      )),
      expect: () => [
        predicate<GroupDetailState>((state) => state.isLoading == true),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false &&
            state.error != null &&
            state.detail == null),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should emit error on generic exception',
      build: () {
        when(mockGetGroupDetails(testGroupId, testCurrentUserId))
            .thenThrow(Exception('Unexpected error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadGroupDetail(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
      )),
      expect: () => [
        predicate<GroupDetailState>((state) => state.isLoading == true),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false &&
            state.error == 'Что-то пошло не так'),
      ],
    );
  });

  group('LeaveGroupPressed', () {
    blocTest<GroupDetailBloc, GroupDetailState>(
      'should leave group successfully when user can leave',
      build: () {
        when(mockLeaveGroup(testGroupId, 'user-789'))
            .thenAnswer((_) async => {});
        return bloc;
      },
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: 'user-789',
        detail: GroupDetail(
          group: testGroup,
          members: testMembers,
          groupAchievements: ['Первый шаг', 'Команда'],
        ),
      ),
      act: (bloc) => bloc.add(LeaveGroupPressed()),
      expect: () => [
        predicate<GroupDetailState>((state) =>
            state.isLoading == true && state.error == null),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false &&
            state.successMessage == 'Вы вышли из группы'),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should show error when owner tries to leave',
      build: () => bloc,
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(LeaveGroupPressed()),
      expect: () => [
        predicate<GroupDetailState>((state) =>
            state.error == 'Создатель не может выйти из группы' &&
            state.isLoading == false),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should handle DioException on leave',
      build: () {
        when(mockLeaveGroup(testGroupId, testCurrentUserId)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: GroupDetail(
          group: GroupEntity(
            id: testGroup.id,
            name: testGroup.name,
            description: testGroup.description,
            createdBy: 'different-user',
            createdAt: testGroup.createdAt,
            isActive: testGroup.isActive,
            habitsCount: testGroup.habitsCount,
          ),
          members: testMembers,
          groupAchievements: [],
        ),
      ),
      act: (bloc) => bloc.add(LeaveGroupPressed()),
      expect: () => [
        predicate<GroupDetailState>((state) => state.isLoading == true),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false && state.error != null),
      ],
    );
  });

  group('RemoveMemberPressed', () {
    blocTest<GroupDetailBloc, GroupDetailState>(
      'should remove member when user is owner',
      build: () {
        when(mockRemoveMember(testGroupId, testMemberId))
            .thenAnswer((_) async => {});
        when(mockGetGroupDetails(testGroupId, testCurrentUserId))
            .thenAnswer((_) async => testDetail);
        return bloc;
      },
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(RemoveMemberPressed(testMemberId)),
      expect: () => [
        predicate<GroupDetailState>((state) =>
            state.isLoading == true && state.error == null),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false && state.detail == testDetail),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should not remove member when user is not owner',
      build: () => bloc,
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: 'different-user',
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(RemoveMemberPressed(testMemberId)),
      expect: () => [],
      verify: (_) {
        verifyNever(mockRemoveMember(any, any));
      },
    );
  });

  group('SendReactionToLeader', () {
    final leader = testMembers[0];

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should send reaction to leader successfully',
      build: () {
        when(mockSendReaction(
          groupId: testGroupId,
          fromUserId: 'user-789',
          toUserId: leader.userId,
        )).thenAnswer((_) async => {});
        when(mockGetGroupDetails(testGroupId, 'user-789'))
            .thenAnswer((_) async => testDetailAfterReaction);
        return bloc;
      },
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: 'user-789',
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(SendReactionToLeader()),
      expect: () => [
        predicate<GroupDetailState>((state) =>
            state.isLoading == true && state.error == null),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false &&
            state.successMessage == 'Реакция отправлена'),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should not send reaction when there is no leader',
      build: () => bloc,
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: GroupDetail(
          group: testGroup,
          members: [],
          groupAchievements: [],
        ),
      ),
      act: (bloc) => bloc.add(SendReactionToLeader()),
      expect: () => [],
      verify: (_) {
        verifyNever(mockSendReaction(
          groupId: anyNamed('groupId'),
          fromUserId: anyNamed('fromUserId'),
          toUserId: anyNamed('toUserId'),
        ));
      },
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should not send reaction when user is the leader',
      build: () => bloc,
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: leader.userId,
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(SendReactionToLeader()),
      expect: () => [],
      verify: (_) {
        verifyNever(mockSendReaction(
          groupId: anyNamed('groupId'),
          fromUserId: anyNamed('fromUserId'),
          toUserId: anyNamed('toUserId'),
        ));
      },
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should handle DioException on send reaction',
      build: () {
        when(mockSendReaction(
          groupId: testGroupId,
          fromUserId: 'user-789',
          toUserId: leader.userId,
        )).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        return bloc;
      },
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: 'user-789',
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(SendReactionToLeader()),
      expect: () => [
        predicate<GroupDetailState>((state) => state.isLoading == true),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false && state.error != null),
      ],
    );
  });

  group('DeleteGroupPressed', () {
    blocTest<GroupDetailBloc, GroupDetailState>(
      'should delete group when user is owner',
      build: () {
        when(mockRepository.deleteGroup(testGroupId, testCurrentUserId))
            .thenAnswer((_) async => {});
        return bloc;
      },
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(DeleteGroupPressed()),
      expect: () => [
        predicate<GroupDetailState>((state) =>
            state.isLoading == true && state.error == null),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false &&
            state.successMessage == 'Группа удалена'),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should not delete group when user is not owner',
      build: () => bloc,
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: 'different-user',
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(DeleteGroupPressed()),
      expect: () => [],
      verify: (_) {
        verifyNever(mockRepository.deleteGroup(any, any));
      },
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'should handle DioException on delete',
      build: () {
        when(mockRepository.deleteGroup(testGroupId, testCurrentUserId))
            .thenThrow(
              DioException(
                requestOptions: RequestOptions(path: '/test'),
                type: DioExceptionType.connectionTimeout,
              ),
            );
        return bloc;
      },
      seed: () => GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: testDetail,
      ),
      act: (bloc) => bloc.add(DeleteGroupPressed()),
      expect: () => [
        predicate<GroupDetailState>((state) => state.isLoading == true),
        predicate<GroupDetailState>((state) =>
            state.isLoading == false && state.error != null),
      ],
    );
  });

  group('Helper properties', () {
    test('isOwner should return true when current user created group', () {
      final state = GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: testDetail,
      );
      expect(state.isOwner, isTrue);
    });

    test('isOwner should return false when different user created group', () {
      final state = GroupDetailState(
        groupId: testGroupId,
        currentUserId: 'different-user',
        detail: testDetail,
      );
      expect(state.isOwner, isFalse);
    });

    test('canLeave should return false when user is owner', () {
      final state = GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: testDetail,
      );
      expect(state.canLeave, isFalse);
    });

    test('canLeave should return true when user is not owner', () {
      final state = GroupDetailState(
        groupId: testGroupId,
        currentUserId: 'different-user',
        detail: testDetail,
      );
      expect(state.canLeave, isTrue);
    });

    test('leader should return member with highest points', () {
      final state = GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: testDetail,
      );
      expect(state.leader?.userId, equals('user-456'));
      expect(state.leader?.points, equals(100));
    });

    test('leader should return null when no members', () {
      final state = GroupDetailState(
        groupId: testGroupId,
        currentUserId: testCurrentUserId,
        detail: GroupDetail(
          group: testGroup,
          members: [],
          groupAchievements: [],
        ),
      );
      expect(state.leader, isNull);
    });
  });
}