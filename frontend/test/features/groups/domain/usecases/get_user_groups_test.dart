import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/groups/domain/usecases/get_user_groups.dart';

import 'get_user_groups_test.mocks.dart';

@GenerateMocks([GroupRepository])
void main() {
  late GetUserGroups useCase;
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    useCase = GetUserGroups(mockRepository);
  });

  final testUserId = 'user-123';
  final testGroups = [
    GroupEntity(
      id: '1',
      name: 'Семья',
      createdBy: testUserId,
      createdAt: DateTime(2026, 1, 1),
    ),
    GroupEntity(
      id: '2',
      name: 'Друзья',
      createdBy: testUserId,
      createdAt: DateTime(2026, 1, 10),
    ),
  ];

  test('should return list of groups for user', () async {
    when(mockRepository.getUserGroups(testUserId))
        .thenAnswer((_) async => testGroups);

    final result = await useCase(testUserId);

    expect(result, equals(testGroups));
    verify(mockRepository.getUserGroups(testUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when user has no groups', () async {
    when(mockRepository.getUserGroups(testUserId))
        .thenAnswer((_) async => []);

    final result = await useCase(testUserId);

    expect(result, isEmpty);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.getUserGroups(testUserId))
        .thenThrow(Exception('Network error'));

    expect(
      () => useCase(testUserId),
      throwsA(isA<Exception>()),
    );
  });
}