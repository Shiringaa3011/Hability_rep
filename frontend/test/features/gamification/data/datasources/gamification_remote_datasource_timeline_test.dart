import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/core/error/exceptions.dart';
import 'package:habitly/features/gamification/data/datasources/gamification_remote_datasource.dart';
import 'package:habitly/features/gamification/data/models/timeline_point_model.dart';
import 'package:habitly/features/gamification/domain/entities/user_stats.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'gamification_remote_datasource_timeline_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late GamificationRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = GamificationRemoteDataSourceImpl(dio: mockDio);
  });

  const tUserId = 'user-123';
  final tTimelineJson = {
    'user_id': tUserId,
    'period': 'week',
    'timeline': [
      {'date': '2026-05-04', 'points': 10},
      {'date': '2026-05-05', 'points': 25},
    ],
  };

  group('getUserTimeline', () {
    test('should return list of TimelinePointModel on status 200', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: tTimelineJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getUserTimeline(tUserId, StatsPeriod.week);

      expect(result, isA<List<TimelinePointModel>>());
      expect(result.length, 2);
      expect(result[0].date, '2026-05-04');
      expect(result[0].points, 10);
      expect(result[1].date, '2026-05-05');
      expect(result[1].points, 25);
    });

    test('should pass correct URL and period query param', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'timeline': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.getUserTimeline(tUserId, StatsPeriod.week);

      verify(mockDio.get(
        '/stats/user/$tUserId/timeline',
        queryParameters: {'period': 'week'},
      ));
    });

    test('should return empty list when timeline array is empty', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'user_id': tUserId, 'period': 'week', 'timeline': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final result = await dataSource.getUserTimeline(tUserId, StatsPeriod.week);

      expect(result, isEmpty);
    });

    test('should use period.name as query parameter for month', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'timeline': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      await dataSource.getUserTimeline(tUserId, StatsPeriod.month);

      verify(mockDio.get(
        '/stats/user/$tUserId/timeline',
        queryParameters: {'period': 'month'},
      ));
    });

    test('should throw ServerException when status code is not 200', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'detail': 'Unprocessable entity'},
            statusCode: 422,
            requestOptions: RequestOptions(path: ''),
          ));

      expect(
        () => dataSource.getUserTimeline(tUserId, StatsPeriod.day),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw NetworkException on connection timeout', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => dataSource.getUserTimeline(tUserId, StatsPeriod.week),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw NetworkException on receive timeout', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(
        () => dataSource.getUserTimeline(tUserId, StatsPeriod.week),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should throw ServerException on generic DioException', () async {
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: ''),
        message: 'Unknown network error',
      ));

      expect(
        () => dataSource.getUserTimeline(tUserId, StatsPeriod.week),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
