import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/domain/entities/group_member_entity.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/groups/domain/usecases/get_group_details.dart';

import 'get_group_details_test.mocks.dart';

@GenerateMocks([GroupRepository])
void main() {
  late GetGroupDetails useCase;
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    useCase = GetGroupDetails(mockRepository);
  });

  final testDetail = GroupDetail(
    group: GroupEntity(
      id: 'group-1',
      name: 'Семья',
      description: 'Наши привычки',
      createdBy: 'user-123',
      createdAt: DateTime(2026, 1, 1),
    ),
    members: [
      GroupMemberEntity(
        id: 'm1',
        userId: 'user-123',
        username: 'Вы',
        points: 100,
        reactions: 2,
        joinedAt: DateTime(2026, 1, 1),
      ),
      GroupMemberEntity(
        id: 'm2',
        userId: 'user-456',
        username: 'Анна',
        points: 80,
        reactions: 0,
        joinedAt: DateTime(2026, 1, 2),
      ),
    ],
    groupAchievements: ['Первая цель'],
  );

  test('should return group details with members', () async {
    when(mockRepository.getGroupDetails('group-1', 'user-123'))
        .thenAnswer((_) async => testDetail);

    final result = await useCase('group-1', 'user-123');

    expect(result.group.name, 'Семья');
    expect(result.members.length, 2);
    expect(result.groupAchievements, ['Первая цель']);
    expect(result.totalGroupPoints, 180);
    expect(result.leader?.username, 'Вы');
    verify(mockRepository.getGroupDetails('group-1', 'user-123')).called(1);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.getGroupDetails(any, any))
        .thenThrow(Exception('Network error'));

    expect(
      () => useCase('group-1', 'user-123'),
      throwsA(isA<Exception>()),
    );
  });
}