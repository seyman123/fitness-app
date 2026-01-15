import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/water_entry.dart';

abstract class WaterRepository {
  Future<Either<Failure, WaterEntry>> addWaterEntry(int amount);
  Future<Either<Failure, List<WaterEntry>>> getTodayWater();
  Future<Either<Failure, List<WaterEntry>>> getWaterEntries({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, void>> deleteWaterEntry(String id);
  Future<Either<Failure, int>> getTodayTotal();
}
