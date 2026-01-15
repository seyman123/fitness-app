import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/nutrition_log.dart';

abstract class NutritionRepository {
  Future<Either<Failure, NutritionLog>> addNutritionLog({
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  });

  Future<Either<Failure, List<NutritionLog>>> getNutritionLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? mealType,
  });

  Future<Either<Failure, Map<String, dynamic>>> getTodayNutrition();

  Future<Either<Failure, void>> deleteNutritionLog(String id);

  Future<Either<Failure, NutritionLog>> updateNutritionLog({
    required String id,
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  });
}
