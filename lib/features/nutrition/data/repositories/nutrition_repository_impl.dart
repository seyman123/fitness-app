import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/nutrition_log.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_local_data_source.dart';
import '../datasources/nutrition_remote_data_source.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionRemoteDataSource remoteDataSource;
  final NutritionLocalDataSource localDataSource;

  NutritionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, NutritionLog>> addNutritionLog({
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    try {
      final result = await remoteDataSource.addNutritionLog(
        mealType: mealType,
        foodName: foodName,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NutritionLog>>> getNutritionLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? mealType,
  }) async {
    try {
      final response = await remoteDataSource.getNutritionLogs(
        startDate: startDate,
        endDate: endDate,
        mealType: mealType,
      );

      // Cache the results
      await localDataSource.cacheNutritionLogs(response.logs);

      return Right(response.logs.map((model) => model.toEntity()).toList());
    } catch (e) {
      // Try to get cached data
      try {
        final cachedLogs = await localDataSource.getCachedNutritionLogs();
        if (cachedLogs.isNotEmpty) {
          return Right(cachedLogs.map((model) => model.toEntity()).toList());
        }
      } catch (_) {}
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTodayNutrition() async {
    try {
      final response = await remoteDataSource.getTodayNutrition();

      // Cache the results
      await localDataSource.cacheNutritionLogs(response.logs);

      return Right({
        'logs': response.logs.map((model) => model.toEntity()).toList(),
        'totals': response.totals,
        'count': response.count,
        'byMealType': response.byMealType?.map(
          (key, value) => MapEntry(
            key,
            value.map((model) => model.toEntity()).toList(),
          ),
        ),
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNutritionLog(String id) async {
    try {
      await remoteDataSource.deleteNutritionLog(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NutritionLog>> updateNutritionLog({
    required String id,
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    try {
      final result = await remoteDataSource.updateNutritionLog(
        id: id,
        mealType: mealType,
        foodName: foodName,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
