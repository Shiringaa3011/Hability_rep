import 'package:hive/hive.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_stats.dart';
import '../models/achievement_model.dart';
import '../models/user_level_model.dart';
import '../models/user_stats_model.dart';

abstract class GamificationLocalDataSource {
  Future<UserLevelModel?> getCachedUserLevel(String userId);

  Future<void> cacheUserLevel(UserLevelModel level);

  Future<UserStatsModel?> getCachedUserStats(String userId, StatsPeriod period);

  Future<void> cacheUserStats(UserStatsModel stats);

  Future<List<AchievementModel>?> getCachedAchievements(String userId);

  Future<void> cacheAchievements(String userId, List<AchievementModel> achievements);

  Future<void> clearCache();
}

class GamificationLocalDataSourceImpl implements GamificationLocalDataSource {
  GamificationLocalDataSourceImpl({required this.hive});

  final HiveInterface hive;

  static const String _levelBoxName = 'user_level';
  static const String _statsBoxName = 'user_stats';
  static const String _achievementsBoxName = 'achievements';
  static const String _cacheTimeBoxName = 'cache_time';

  @override
  Future<UserLevelModel?> getCachedUserLevel(String userId) async {
    try {
      final box = await hive.openBox<Map>(_levelBoxName);
      final cacheTimeBox = await hive.openBox<DateTime>(_cacheTimeBoxName);

      final cacheTime = cacheTimeBox.get('level_$userId');
      if (cacheTime != null) {
        final age = DateTime.now().difference(cacheTime);
        if (age > ApiConstants.levelCache) {
          await box.delete(userId);
          await cacheTimeBox.delete('level_$userId');
          return null;
        }
      }

      final data = box.get(userId);
      if (data == null) return null;

      return UserLevelModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw CacheException('Failed to get cached level: $e');
    }
  }

  @override
  Future<void> cacheUserLevel(UserLevelModel level) async {
    try {
      final box = await hive.openBox<Map>(_levelBoxName);
      final cacheTimeBox = await hive.openBox<DateTime>(_cacheTimeBoxName);

      await box.put(level.userId, level.toJson());
      await cacheTimeBox.put('level_${level.userId}', DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache level: $e');
    }
  }

  @override
  Future<UserStatsModel?> getCachedUserStats(String userId, StatsPeriod period) async {
    try {
      final box = await hive.openBox<Map>(_statsBoxName);
      final cacheTimeBox = await hive.openBox<DateTime>(_cacheTimeBoxName);

      final key = '${userId}_${period.name}';
      final cacheTime = cacheTimeBox.get('stats_$key');
      
      if (cacheTime != null) {
        final age = DateTime.now().difference(cacheTime);
        if (age > ApiConstants.statsCache) {
          await box.delete(key);
          await cacheTimeBox.delete('stats_$key');
          return null;
        }
      }

      final data = box.get(key);
      if (data == null) return null;

      return UserStatsModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw CacheException('Failed to get cached stats: $e');
    }
  }

  @override
  Future<void> cacheUserStats(UserStatsModel stats) async {
    try {
      final box = await hive.openBox<Map>(_statsBoxName);
      final cacheTimeBox = await hive.openBox<DateTime>(_cacheTimeBoxName);

      final key = '${stats.userId}_${stats.period}';
      await box.put(key, stats.toJson());
      await cacheTimeBox.put('stats_$key', DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache stats: $e');
    }
  }

  @override
  Future<List<AchievementModel>?> getCachedAchievements(String userId) async {
    try {
      final box = await hive.openBox<List>(_achievementsBoxName);
      final cacheTimeBox = await hive.openBox<DateTime>(_cacheTimeBoxName);

      final cacheTime = cacheTimeBox.get('achievements_$userId');
      if (cacheTime != null) {
        final age = DateTime.now().difference(cacheTime);
        if (age > ApiConstants.achievementsCache) {
          await box.delete(userId);
          await cacheTimeBox.delete('achievements_$userId');
          return null;
        }
      }

      final data = box.get(userId);
      if (data == null) return null;

      return data
          .map((item) => AchievementModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached achievements: $e');
    }
  }

  @override
  Future<void> cacheAchievements(String userId, List<AchievementModel> achievements) async {
    try {
      final box = await hive.openBox<List>(_achievementsBoxName);
      final cacheTimeBox = await hive.openBox<DateTime>(_cacheTimeBoxName);

      final data = achievements.map((a) => a.toJson()).toList();
      await box.put(userId, data);
      await cacheTimeBox.put('achievements_$userId', DateTime.now());
    } catch (e) {
      throw CacheException('Failed to cache achievements: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await hive.deleteBoxFromDisk(_levelBoxName);
      await hive.deleteBoxFromDisk(_statsBoxName);
      await hive.deleteBoxFromDisk(_achievementsBoxName);
      await hive.deleteBoxFromDisk(_cacheTimeBoxName);
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }
}
