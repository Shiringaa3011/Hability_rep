import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/home/domain/entities/today_habit_entity.dart';
import 'package:habitly/features/home/data/repositories/home_repository_impl.dart';
import 'package:habitly/features/home/data/datasources/habit_local_datasource.dart';

import 'home_repository_impl_test.mocks.dart';

@GenerateMocks([Dio, GroupRepository, HabitLocalDataSource])
void main() {
  late HomeRepositoryImpl repository;
  late MockDio mockDio;
  late MockGroupRepository mockGroupRepository;
  late MockHabitLocalDataSource mockLocalDataSource;

  const testUserId = 'user-123';
  const testHabitId = 'habit-456';
  const testGroupId = 'group-789';
  final testDay = DateTime(2026, 5, 24);

  final testGroups = [
    GroupEntity(
      id: testGroupId,
      name: 'Семья',
      createdBy: 'user-456',
      createdAt: DateTime(2026, 1, 1),
    ),
    GroupEntity(
      id: 'group-2',
      name: 'Друзья',
      createdBy: 'user-789',
      createdAt: DateTime(2026, 1, 15),
    ),
  ];

  final testHabitsResponse = {
    'habits': [
      {
        'id': 'habit-1',
        'title': 'Утренняя зарядка',
        'description': 'Делать зарядку',
        'scheduled_time': '08:00',
        'frequency': 'daily',
        'completed_today': false,
        'group_id': null,
        'group_name': null,
        'reminders_enabled': true,
        'reminder_time': '07:55',
      },
      {
        'id': 'habit-2',
        'title': 'Чтение книги',
        'description': 'Читать 30 минут',
        'scheduled_time': '21:00',
        'frequency': 'weekly',
        'completed_today': true,
        'group_id': testGroupId,
        'group_name': 'Семья',
        'reminders_enabled': false,
        'reminder_time': null,
      },
    ],
  };

  final testHabits = [
    TodayHabitEntity(
      id: 'habit-1',
      title: 'Утренняя зарядка',
      description: 'Делать зарядку',
      scheduledTimeLabel: '08:00',
      frequencyLabel: 'Ежедневно',
      completedToday: false,
      groupId: null,
      groupName: null,
      remindersEnabled: true,
      reminderTimeLabel: '07:55',
    ),
    TodayHabitEntity(
      id: 'habit-2',
      title: 'Чтение книги',
      description: 'Читать 30 минут',
      scheduledTimeLabel: '21:00',
      frequencyLabel: 'Еженедельно',
      completedToday: true,
      groupId: testGroupId,
      groupName: 'Семья',
      remindersEnabled: false,
      reminderTimeLabel: null,
    ),
  ];

  setUp(() {
    mockDio = MockDio();
    mockGroupRepository = MockGroupRepository();
    mockLocalDataSource = MockHabitLocalDataSource();
    repository = HomeRepositoryImpl(
      mockGroupRepository,
      dio: mockDio,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getHabitsForDay', () {
    test('should return cached habits when available', () async {
      when(mockLocalDataSource.getCachedHabits(testUserId, testDay))
          .thenReturn(testHabits);

      final result = await repository.getHabitsForDay(
        userId: testUserId,
        day: testDay,
      );

      expect(result, equals(testHabits));
      verify(mockLocalDataSource.getCachedHabits(testUserId, testDay)).called(1);
    });

    test('should fetch from network when cache is empty', () async {
      when(mockLocalDataSource.getCachedHabits(testUserId, testDay))
          .thenReturn(null);
      when(mockDio.get(
        '/habits/user/$testUserId/day',
        queryParameters: {'day': '2026-05-24'},
      )).thenAnswer(
        (_) async => Response(
          data: testHabitsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/habits/user/$testUserId/day'),
        ),
      );
      when(mockLocalDataSource.cacheHabits(testUserId, testDay, any))
          .thenAnswer((_) async => {});

      final result = await repository.getHabitsForDay(
        userId: testUserId,
        day: testDay,
      );

      expect(result.length, equals(2));
      verify(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).called(1);
      verify(mockLocalDataSource.cacheHabits(testUserId, testDay, any)).called(1);
    });

    test('should filter habits by groupId', () async {
      when(mockLocalDataSource.getCachedHabits(testUserId, testDay))
          .thenReturn(testHabits);

      final result = await repository.getHabitsForDay(
        userId: testUserId,
        day: testDay,
        groupId: testGroupId,
      );

      expect(result.length, equals(1));
      expect(result[0].groupId, equals(testGroupId));
    });

    test('should force refresh when forceRefresh = true', () async {
      when(mockLocalDataSource.getCachedHabits(testUserId, testDay))
          .thenReturn(testHabits);
      when(mockDio.get(
        '/habits/user/$testUserId/day',
        queryParameters: {'day': '2026-05-24'},
      )).thenAnswer(
        (_) async => Response(
          data: testHabitsResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/habits/user/$testUserId/day'),
        ),
      );
      when(mockLocalDataSource.cacheHabits(testUserId, testDay, any))
          .thenAnswer((_) async => {});

      final result = await repository.getHabitsForDay(
        userId: testUserId,
        day: testDay,
        forceRefresh: true,
      );

      expect(result.length, equals(2));
      verifyNever(mockLocalDataSource.getCachedHabits(testUserId, testDay));
      verify(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).called(1);
    });

    test('should rethrow on network error when cache empty', () async {
      when(mockLocalDataSource.getCachedHabits(testUserId, testDay))
          .thenReturn(null);
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: '/test'),
            type: DioExceptionType.connectionTimeout,
          ));

      expect(
        () => repository.getHabitsForDay(
          userId: testUserId,
          day: testDay,
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('getGroupFilterOptions', () {
    test('should return "Все группы" plus user groups', () async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => testGroups);

      final result = await repository.getGroupFilterOptions(testUserId);

      expect(result.length, equals(3));
      expect(result[0].groupId, isNull);
      expect(result[0].title, equals('Все группы'));
      expect(result[1].groupId, equals(testGroupId));
      expect(result[1].title, equals('Семья'));
      expect(result[2].groupId, equals('group-2'));
      expect(result[2].title, equals('Друзья'));
    });

    test('should return only "Все группы" when user has no groups', () async {
      when(mockGroupRepository.getUserGroups(testUserId))
          .thenAnswer((_) async => []);

      final result = await repository.getGroupFilterOptions(testUserId);

      expect(result.length, equals(1));
      expect(result[0].groupId, isNull);
      expect(result[0].title, equals('Все группы'));
    });
  });

  group('setHabitCompletedForDay', () {
    test('should send POST request and invalidate cache', () async {
      when(mockDio.post(
        '/habits/$testHabitId/completion',
        data: {
          'day': '2026-05-24',
          'completed': true,
          'user_id': testUserId,
        },
      )).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/habits/$testHabitId/completion'),
        ),
      );
      when(mockLocalDataSource.invalidateDay(testUserId, testDay))
          .thenAnswer((_) async => {});

      await repository.setHabitCompletedForDay(
        habitId: testHabitId,
        day: testDay,
        completed: true,
        userId: testUserId,
      );

      verify(mockDio.post(
        '/habits/$testHabitId/completion',
        data: {
          'day': '2026-05-24',
          'completed': true,
          'user_id': testUserId,
        },
      )).called(1);
      verify(mockLocalDataSource.invalidateDay(testUserId, testDay)).called(1);
    });

    test('should not invalidate cache when userId is null', () async {
      when(mockDio.post(
        '/habits/$testHabitId/completion',
        data: {
          'day': '2026-05-24',
          'completed': false,
          'user_id': null,
        },
      )).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/habits/$testHabitId/completion'),
        ),
      );

      await repository.setHabitCompletedForDay(
        habitId: testHabitId,
        day: testDay,
        completed: false,
        userId: null,
      );

      verifyNever(mockLocalDataSource.invalidateDay(any, any));
    });
  });

  group('getHabitById', () {
    final habitResponse = {
      'id': testHabitId,
      'title': 'Медитация',
      'description': 'Утренняя медитация',
      'scheduled_time': '07:00',
      'frequency': 'daily',
      'completed_today': false,
      'group_id': null,
      'group_name': null,
      'reminders_enabled': true,
      'reminder_time': '06:55',
    };

    test('should return habit when found', () async {
      when(mockDio.get(
        '/habits/$testHabitId',
        queryParameters: {'user_id': testUserId},
      )).thenAnswer(
        (_) async => Response(
          data: habitResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/habits/$testHabitId'),
        ),
      );

      final result = await repository.getHabitById(testHabitId, testUserId);

      expect(result, isNotNull);
      expect(result!.id, equals(testHabitId));
      expect(result.title, equals('Медитация'));
      expect(result.frequencyLabel, equals('Ежедневно'));
    });

    test('should return null when 404', () async {
      when(mockDio.get(
        '/habits/$testHabitId',
        queryParameters: {'user_id': testUserId},
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/habits/$testHabitId'),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/habits/$testHabitId'),
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getHabitById(testHabitId, testUserId);

      expect(result, isNull);
    });

    test('should rethrow on other errors', () async {
      when(mockDio.get(
        '/habits/$testHabitId',
        queryParameters: {'user_id': testUserId},
      )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/habits/$testHabitId'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repository.getHabitById(testHabitId, testUserId),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('upsertHabitDefinition', () {
    final newHabit = TodayHabitEntity(
      id: 'h_123456',
      title: 'Новая привычка',
      description: 'Описание',
      scheduledTimeLabel: '10:00',
      frequencyLabel: 'Ежедневно',
      completedToday: false,
      groupId: null,
      groupName: null,
      remindersEnabled: true,
      reminderTimeLabel: '09:50',
    );

    final weeklyHabit = TodayHabitEntity(
      id: 'h_789012',
      title: 'Еженедельная привычка',
      description: null,
      scheduledTimeLabel: '15:00',
      frequencyLabel: 'Еженедельно',
      completedToday: false,
      groupId: testGroupId,
      groupName: 'Семья',
      remindersEnabled: false,
      reminderTimeLabel: null,
      dayOfWeek: 3,
    );

    final existingHabit = TodayHabitEntity(
      id: 'existing-123',
      title: 'Существующая привычка',
      description: 'Старое описание',
      scheduledTimeLabel: '12:00',
      frequencyLabel: 'Ежедневно',
      completedToday: false,
      groupId: null,
      groupName: null,
      remindersEnabled: false,
      reminderTimeLabel: null,
    );

    setUp(() {
      when(mockLocalDataSource.invalidateDay(testUserId, any))
          .thenAnswer((_) async => {});
    });

    test('should create new habit with POST', () async {
      when(mockDio.post('/habits', data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: {'id': 'new-id'},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/habits'),
        ),
      );

      await repository.upsertHabitDefinition(testUserId, newHabit);

      verify(mockDio.post('/habits', data: {
        'user_id': testUserId,
        'title': 'Новая привычка',
        'description': 'Описание',
        'group_id': null,
        'frequency': 'daily',
        'scheduled_time': '10:00',
        'reminders_enabled': true,
        'reminder_time': '09:50',
      })).called(1);
      verify(mockLocalDataSource.invalidateDay(testUserId, any)).called(1);
    });

    test('should create weekly habit with day_of_week', () async {
      when(mockDio.post('/habits', data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: {'id': 'new-id'},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/habits'),
        ),
      );

      await repository.upsertHabitDefinition(testUserId, weeklyHabit);

      verify(mockDio.post('/habits', data: {
        'user_id': testUserId,
        'title': 'Еженедельная привычка',
        'description': null,
        'group_id': testGroupId,
        'frequency': 'weekly',
        'scheduled_time': '15:00',
        'reminders_enabled': false,
        'reminder_time': null,
        'day_of_week': 3,
      })).called(1);
    });

    test('should update existing habit with PUT', () async {
      when(mockDio.put('/habits/existing-123', data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/habits/existing-123'),
        ),
      );

      await repository.upsertHabitDefinition(testUserId, existingHabit);

      verify(mockDio.put('/habits/existing-123', data: {
        'user_id': testUserId,
        'title': 'Существующая привычка',
        'description': 'Старое описание',
        'group_id': null,
        'frequency': 'daily',
        'scheduled_time': '12:00',
        'reminders_enabled': false,
        'reminder_time': null,
      })).called(1);
    });
  });

  group('deleteHabit', () {
    test('should send DELETE request and invalidate cache', () async {
      when(mockDio.delete(
        '/habits/$testHabitId',
        queryParameters: {'user_id': testUserId},
      )).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/habits/$testHabitId'),
        ),
      );
      when(mockLocalDataSource.invalidateDay(testUserId, any))
          .thenAnswer((_) async => {});

      await repository.deleteHabit(testHabitId, testUserId);

      verify(mockDio.delete(
        '/habits/$testHabitId',
        queryParameters: {'user_id': testUserId},
      )).called(1);
      verify(mockLocalDataSource.invalidateDay(testUserId, any)).called(1);
    });
  });
}