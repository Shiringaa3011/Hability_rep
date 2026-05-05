import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/notifications/domain/entities/notification_history_item.dart';
import 'package:habitly/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:habitly/features/notifications/domain/usecases/get_notification_history.dart';

import 'get_notification_history_test.mocks.dart';

@GenerateMocks([NotificationsRepository])
void main() {
  late GetNotificationHistory useCase;
  late MockNotificationsRepository mockRepository;

  const testUserId = 'user-123';

  final List<NotificationHistoryItem> testHistory = [
    NotificationHistoryItem(
      id: 'notif-1',
      title: 'Напоминание',
      body: 'Пора сделать зарядку',
      receivedAt: DateTime.parse('2026-05-24T08:00:00Z'),
      read: false,
    ),
    NotificationHistoryItem(
      id: 'notif-2',
      title: 'Достижение',
      body: 'Вы получили новую награду',
      receivedAt: DateTime.parse('2026-05-23T18:30:00Z'),
      read: true,
    ),
  ];

  setUp(() {
    mockRepository = MockNotificationsRepository();
    useCase = GetNotificationHistory(mockRepository);
  });

  test('should return notification history from repository', () async {
    when(mockRepository.getHistory(testUserId))
        .thenAnswer((_) async => testHistory);

    final result = await useCase(testUserId);

    expect(result, equals(testHistory));
    expect(result.length, equals(2));
    expect(result[0].title, equals('Напоминание'));
    expect(result[1].title, equals('Достижение'));
    verify(mockRepository.getHistory(testUserId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when repository returns empty', () async {
    when(mockRepository.getHistory(testUserId))
        .thenAnswer((_) async => []);

    final result = await useCase(testUserId);

    expect(result, isEmpty);
    verify(mockRepository.getHistory(testUserId)).called(1);
  });

  test('should propagate error from repository', () async {
    when(mockRepository.getHistory(testUserId))
        .thenThrow(Exception('Network error'));

    expect(
      () => useCase(testUserId),
      throwsA(isA<Exception>()),
    );
  });
}