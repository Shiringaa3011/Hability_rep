import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/home/domain/repositories/home_repository.dart';
import 'package:habitly/features/home/domain/usecases/get_home_group_filter_options.dart';

import 'get_home_group_filter_options_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  late GetHomeGroupFilterOptions useCase;
  late MockHomeRepository mockRepository;

  const testUserId = 'user-123';

  final testOptions = [
    const HomeGroupFilterOption(groupId: null, title: 'Все группы'),
    const HomeGroupFilterOption(groupId: 'group-1', title: 'Семья'),
    const HomeGroupFilterOption(groupId: 'group-2', title: 'Друзья'),
  ];

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetHomeGroupFilterOptions(mockRepository);
  });

  test('should return filter options from repository', () async {
    when(mockRepository.getGroupFilterOptions(testUserId))
        .thenAnswer((_) async => testOptions);

    final result = await useCase(testUserId);

    expect(result, equals(testOptions));
    expect(result.length, equals(3));
    expect(result[0].title, equals('Все группы'));
    verify(mockRepository.getGroupFilterOptions(testUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when repository returns empty', () async {
    when(mockRepository.getGroupFilterOptions(testUserId))
        .thenAnswer((_) async => []);

    final result = await useCase(testUserId);

    expect(result, isEmpty);
    verify(mockRepository.getGroupFilterOptions(testUserId)).called(1);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.getGroupFilterOptions(testUserId))
        .thenThrow(Exception('Network error'));

    expect(
      () => useCase(testUserId),
      throwsA(isA<Exception>()),
    );
  });
}