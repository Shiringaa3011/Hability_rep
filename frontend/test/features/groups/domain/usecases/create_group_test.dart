import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/groups/domain/usecases/create_group.dart';

import 'create_group_test.mocks.dart';

@GenerateMocks([GroupRepository])
void main() {
  late CreateGroup useCase;
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    useCase = CreateGroup(mockRepository);
  });

  final testGroup = GroupEntity(
    id: 'new-group-id',
    name: 'Новая группа',
    description: 'Описание группы',
    createdBy: 'user-123',
    createdAt: DateTime(2026, 1, 1),
  );

  test('should create and return a group', () async {
    when(mockRepository.createGroup(
      creatorUserId: 'user-123',
      name: 'Новая группа',
      description: 'Описание группы',
    )).thenAnswer((_) async => testGroup);

    final result = await useCase(
      creatorUserId: 'user-123',
      name: 'Новая группа',
      description: 'Описание группы',
    );

    expect(result, equals(testGroup));
    expect(result.name, 'Новая группа');
    expect(result.createdBy, 'user-123');
    verify(mockRepository.createGroup(
      creatorUserId: 'user-123',
      name: 'Новая группа',
      description: 'Описание группы',
    )).called(1);
  });

  test('should create group without description', () async {
    when(mockRepository.createGroup(
      creatorUserId: 'user-123',
      name: 'Без описания',
      description: null,
    )).thenAnswer((_) async => testGroup);

    final result = await useCase(
      creatorUserId: 'user-123',
      name: 'Без описания',
    );

    expect(result, isNotNull);
    verify(mockRepository.createGroup(
      creatorUserId: 'user-123',
      name: 'Без описания',
      description: null,
    )).called(1);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.createGroup(
      creatorUserId: anyNamed('creatorUserId'),
      name: anyNamed('name'),
      description: anyNamed('description'),
    )).thenThrow(Exception('Network error'));

    expect(
      () => useCase(
        creatorUserId: 'user-123',
        name: 'Test',
      ),
      throwsA(isA<Exception>()),
    );
  });
}