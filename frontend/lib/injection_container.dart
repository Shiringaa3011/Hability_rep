import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import 'core/network/dio_client.dart';
import 'features/gamification/data/datasources/gamification_local_datasource.dart';
import 'features/gamification/data/datasources/gamification_remote_datasource.dart';
import 'features/gamification/data/repositories/gamification_repository_impl.dart';
import 'features/gamification/domain/repositories/gamification_repository.dart';
import 'features/gamification/domain/usecases/complete_habit.dart';
import 'features/gamification/domain/usecases/get_achievements.dart';
import 'features/gamification/domain/usecases/get_group_achievements.dart';
import 'features/gamification/domain/usecases/get_group_stats.dart';
import 'features/gamification/domain/usecases/get_habits_stats.dart';
import 'features/gamification/domain/usecases/get_user_level.dart';
import 'features/gamification/domain/usecases/get_user_stats.dart';
import 'features/gamification/presentation/bloc/achievements/achievements_bloc.dart';
import 'features/gamification/presentation/bloc/group_achievements/group_achievements_bloc.dart';
import 'features/gamification/presentation/bloc/group_stats/group_stats_bloc.dart';
import 'features/gamification/presentation/bloc/level/level_bloc.dart';
import 'features/gamification/presentation/bloc/stats/stats_bloc.dart';

import 'features/groups/data/repositories/group_repository_impl.dart';
import 'features/groups/domain/repositories/group_repository.dart';
import 'features/groups/domain/usecases/get_group_details.dart';
import 'features/groups/domain/usecases/get_user_groups.dart';
import 'features/groups/domain/usecases/join_group.dart';
import 'features/groups/domain/usecases/leave_group.dart';
import 'features/groups/domain/usecases/remove_member.dart';
import 'features/groups/domain/usecases/send_reaction.dart';
import 'features/groups/domain/usecases/create_group.dart';

import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_home_group_filter_options.dart';
import 'features/home/domain/usecases/get_today_habits_for_day.dart';
import 'features/home/domain/usecases/toggle_habit_completion.dart';
import 'features/home/domain/usecases/get_habit_by_id.dart';
import 'features/home/domain/usecases/upsert_habit_definition.dart';

import 'features/notifications/data/repositories/notifications_repository_impl.dart';
import 'features/notifications/domain/repositories/notifications_repository.dart';
import 'features/notifications/domain/usecases/get_notification_history.dart';
import 'features/notifications/domain/usecases/get_notification_settings.dart';
import 'features/notifications/domain/usecases/mark_notification_read.dart';
import 'features/notifications/domain/usecases/save_notification_settings.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<Dio>(() => createDioClient());

  sl.registerLazySingleton<HiveInterface>(() => Hive);

  sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl());
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl(), sl<GamificationRemoteDataSource>()),
  );
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl());

  sl.registerLazySingleton(() => GetUserGroups(sl()));
  sl.registerLazySingleton(() => GetGroupDetails(sl()));
  sl.registerLazySingleton(() => LeaveGroup(sl()));
  sl.registerLazySingleton(() => RemoveMember(sl()));
  sl.registerLazySingleton(() => SendReaction(sl()));
  sl.registerLazySingleton(() => const JoinGroup());
  sl.registerLazySingleton(() => CreateGroup(sl()));

  sl.registerLazySingleton(() => GetTodayHabitsForDay(sl()));
  sl.registerLazySingleton(() => GetHomeGroupFilterOptions(sl()));
  sl.registerLazySingleton(() => ToggleHabitCompletion(sl()));
  sl.registerLazySingleton(() => GetHabitById(sl()));
  sl.registerLazySingleton(() => UpsertHabitDefinition(sl()));

  sl.registerLazySingleton(() => GetNotificationHistory(sl()));
  sl.registerLazySingleton(() => MarkNotificationRead(sl()));
  sl.registerLazySingleton(() => GetNotificationSettings(sl()));
  sl.registerLazySingleton(() => SaveNotificationSettings(sl()));

  await _initGamification();
}

Future<void> _initGamification() async {
  sl.registerFactory(
    () => LevelBloc(getUserLevel: sl()),
  );

  sl.registerFactory(
    () => StatsBloc(
      getUserStats: sl(),
      getHabitsStats: sl(),
      completeHabit: sl(),
    ),
  );

  sl.registerFactory(
    () => AchievementsBloc(getAchievements: sl()),
  );

  sl.registerFactory(
    () => GroupAchievementsBloc(getGroupAchievements: sl()),
  );

  sl.registerFactory(
    () => GroupStatsBloc(getGroupStats: sl()),
  );

  sl.registerLazySingleton(() => GetUserLevel(sl()));
  sl.registerLazySingleton(() => GetUserStats(sl()));
  sl.registerLazySingleton(() => GetHabitsStats(sl()));
  sl.registerLazySingleton(() => GetAchievements(sl()));
  sl.registerLazySingleton(() => GetGroupAchievements(sl()));
  sl.registerLazySingleton(() => GetGroupStats(sl()));
  sl.registerLazySingleton(() => CompleteHabit(sl()));

  sl.registerLazySingleton<GamificationRepository>(
    () => GamificationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<GamificationRemoteDataSource>(
    () => GamificationRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<GamificationLocalDataSource>(
    () => GamificationLocalDataSourceImpl(hive: sl()),
  );
}
