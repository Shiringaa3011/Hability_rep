import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_stats.dart';
import '../models/achievement_model.dart';
import '../models/group_stats_model.dart';
import '../models/habit_stats_model.dart';
import '../models/user_level_model.dart';
import '../models/user_stats_model.dart';

abstract class GamificationRemoteDataSource {
  Future<UserLevelModel> getUserLevel(String userId);

  Future<UserStatsModel> getUserStats(String userId, StatsPeriod period);

  Future<List<HabitStatsModel>> getUserHabitsStats(String userId, StatsPeriod period);

  Future<List<AchievementModel>> getAchievements(String userId);

  Future<List<NewAchievementInfo>> completeHabit(String habitId, String userId);

  Future<List<Map<String, dynamic>>> getGroupAchievements(String groupId);

  Future<GroupStatsModel> getGroupStats(String groupId, StatsPeriod period);
}

class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  GamificationRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<UserLevelModel> getUserLevel(String userId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.gamificationPath}/user/$userId/level',
      );

      if (response.statusCode == 200) {
        return UserLevelModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get user level: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('User not found');
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<UserStatsModel> getUserStats(String userId, StatsPeriod period) async {
    try {
      final response = await dio.get(
        '${ApiConstants.statsPath}/user/$userId',
        queryParameters: {'period': period.name},
      );

      if (response.statusCode == 200) {
        return UserStatsModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get user stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<List<HabitStatsModel>> getUserHabitsStats(
    String userId,
    StatsPeriod period,
  ) async {
    try {
      final response = await dio.get(
        '${ApiConstants.statsPath}/user/$userId/habits',
        queryParameters: {'period': period.name},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final habits = data['habits'] as List<dynamic>;
        return habits
            .map((habit) => HabitStatsModel.fromJson(habit as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to get habits stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<List<AchievementModel>> getAchievements(String userId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.achievementsPath}/user/$userId/progress',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final achievements = data['achievements'] as List<dynamic>;
        return achievements
            .map((ach) => AchievementModel.fromJson(ach as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException('Failed to get achievements: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<List<NewAchievementInfo>> completeHabit(String habitId, String userId) async {
    try {
      final response = await dio.post(
        '${ApiConstants.gamificationPath}/complete-habit',
        data: {
          'habit_id': habitId,
          'user_id': userId,
          'completion_date': DateTime.now().toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final rawList = data['new_achievements'] as List<dynamic>? ?? [];
        return rawList.map((item) {
          final m = item as Map<String, dynamic>;
          return NewAchievementInfo(
            achievementId: m['achievement_id'] as String,
            name: m['name'] as String,
            icon: m['icon'] as String,
            rewardPoints: m['reward_points'] as int,
          );
        }).toList();
      } else {
        throw ServerException('Failed to complete habit: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['detail'] ?? 'Bad request';
        throw ServerException(message);
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<GroupStatsModel> getGroupStats(String groupId, StatsPeriod period) async {
    try {
      final response = await dio.get(
        '${ApiConstants.statsPath}/group/$groupId',
        queryParameters: {'period': period.name},
      );

      if (response.statusCode == 200) {
        return GroupStatsModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get group stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('Group not found');
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGroupAchievements(String groupId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.achievementsPath}/group/$groupId/progress',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final achievements = data['achievements'] as List<dynamic>;
        return achievements
            .map((a) => a as Map<String, dynamic>)
            .toList();
      } else {
        throw ServerException(
          'Failed to get group achievements: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    }
  }
}
