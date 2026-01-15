import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weight_entry.dart';
import '../../data/models/weight_response_model.dart';

abstract class WeightRepository {
  Future<Either<Failure, WeightEntry>> createWeightEntry({
    required double weight,
    double? bmi,
    String? notes,
    DateTime? date,
  });

  Future<Either<Failure, List<WeightEntry>>> getWeightHistory({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, WeightStatsModel>> getWeightStats({int days});

  Future<Either<Failure, void>> deleteWeightEntry(String id);
}
