import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/step_entry.dart';

abstract class StepsRepository {
  Future<Either<Failure, StepEntry>> addSteps({
    required int steps,
    DateTime? date,
  });

  Future<Either<Failure, int>> getTodaySteps();

  Future<Either<Failure, List<StepEntry>>> getStepsHistory({
    DateTime? startDate,
    DateTime? endDate,
  });
}
