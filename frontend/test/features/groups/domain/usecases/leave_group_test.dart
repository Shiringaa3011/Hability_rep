import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/groups/domain/usecases/leave_group.dart';

import 'leave_group_test.mocks.dart';

@GenerateMocks([GroupRepository])
void main() {
  late LeaveGroup useCase;
  late MockGroupRepository mockRepository;

  setUp(() {
    mockRepository = MockGroupRepository();
    useCase = LeaveGroup(mockRepository);
  });

  test('should leave group successfully', () async {
    when(mockRepository.leaveGroup('group-1', 'user-123'))
        .thenAnswer((_) async => {});

    await useCase('group-1', 'user-123');

    verify(mockRepository.leaveGroup('group-1', 'user-123')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should propagate error when leave fails', () async {
    when(mockRepository.leaveGroup('group-1', 'user-123'))
        .thenThrow(Exception('Cannot leave'));

    expect(
      () => useCase('group-1', 'user-123'),
      throwsA(isA<Exception>()),
    );
  });
}