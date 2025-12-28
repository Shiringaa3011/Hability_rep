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
import 'features/gamification/domain/usecases/get_habits_stats.dart';
import 'features/gamification/domain/usecases/get_user_level.dart';
import 'features/gamification/domain/usecases/get_user_stats.dart';
import 'features/gamification/presentation/bloc/achievements/achievements_bloc.dart';
import 'features/gamification/presentation/bloc/level/level_bloc.dart';
import 'features/gamification/presentation/bloc/stats/stats_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<Dio>(() => createDioClient());

  sl.registerLazySingleton<HiveInterface>(() => Hive);

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
    ),
  );

  sl.registerFactory(
    () => AchievementsBloc(getAchievements: sl()),
  );

  sl.registerLazySingleton(() => GetUserLevel(sl()));
  sl.registerLazySingleton(() => GetUserStats(sl()));
  sl.registerLazySingleton(() => GetHabitsStats(sl()));
  sl.registerLazySingleton(() => GetAchievements(sl()));
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
