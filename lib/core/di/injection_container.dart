import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/workout/data/datasources/workout_remote_data_source.dart';
import '../../features/workout/data/repositories/workout_repository_impl.dart';
import '../../features/workout/domain/repositories/workout_repository.dart';
import '../../features/workout/presentation/bloc/workout_bloc.dart';
import '../../features/water/data/datasources/water_local_data_source.dart';
import '../../features/water/data/datasources/water_remote_data_source.dart';
import '../../features/water/data/repositories/water_repository_impl.dart';
import '../../features/water/domain/repositories/water_repository.dart';
import '../../features/water/presentation/bloc/water_bloc.dart';
import '../../features/nutrition/data/datasources/nutrition_local_data_source.dart';
import '../../features/nutrition/data/datasources/nutrition_remote_data_source.dart';
import '../../features/nutrition/data/repositories/nutrition_repository_impl.dart';
import '../../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../../features/nutrition/presentation/bloc/nutrition_bloc.dart';
import '../../features/steps/data/datasources/steps_local_data_source.dart';
import '../../features/steps/data/datasources/steps_remote_data_source.dart';
import '../../features/steps/data/repositories/steps_repository_impl.dart';
import '../../features/steps/domain/repositories/steps_repository.dart';
import '../../features/steps/presentation/bloc/steps_bloc.dart';
import '../../features/weight/data/datasources/weight_remote_data_source.dart';
import '../../features/weight/data/repositories/weight_repository_impl.dart';
import '../../features/weight/domain/repositories/weight_repository.dart';
import '../../features/weight/presentation/bloc/weight_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ! Features - Profile
  // Bloc
  sl.registerFactory(
    () => ProfileBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      apiClient: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ! Features - Workout
  // Bloc
  sl.registerFactory(
    () => WorkoutBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<WorkoutRemoteDataSource>(
    () => WorkoutRemoteDataSourceImpl(
      apiClient: sl(),
      sharedPreferences: sl(),
    ),
  );

  // ! Features - Water
  // Bloc
  sl.registerFactory(
    () => WaterBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<WaterRepository>(
    () => WaterRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<WaterRemoteDataSource>(
    () => WaterRemoteDataSourceImpl(
      apiClient: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<WaterLocalDataSource>(
    () => WaterLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ! Features - Nutrition
  // Bloc
  sl.registerFactory(
    () => NutritionBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<NutritionRepository>(
    () => NutritionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<NutritionRemoteDataSource>(
    () => NutritionRemoteDataSourceImpl(
      apiClient: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<NutritionLocalDataSource>(
    () => NutritionLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ! Features - Steps
  // Bloc
  sl.registerFactory(
    () => StepsBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<StepsRepository>(
    () => StepsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<StepsRemoteDataSource>(
    () => StepsRemoteDataSourceImpl(
      apiClient: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<StepsLocalDataSource>(
    () => StepsLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ! Features - Weight
  // Bloc
  sl.registerFactory(
    () => WeightBloc(repository: sl()),
  );

  // Repository
  sl.registerLazySingleton<WeightRepository>(
    () => WeightRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<WeightRemoteDataSource>(
    () => WeightRemoteDataSourceImpl(
      client: sl(),
    ),
  );

  // ! Core
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(),
  );

  // ! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}
