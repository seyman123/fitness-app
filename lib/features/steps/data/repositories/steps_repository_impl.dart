import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/step_entry.dart';
import '../../domain/repositories/steps_repository.dart';
import '../datasources/steps_local_data_source.dart';
import '../datasources/steps_remote_data_source.dart';

class StepsRepositoryImpl implements StepsRepository {
  final StepsRemoteDataSource remoteDataSource;
  final StepsLocalDataSource localDataSource;

  StepsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, StepEntry>> addSteps({
    required int steps,
    DateTime? date,
  }) async {
    try {
      final result = await remoteDataSource.addSteps(
        steps: steps,
        date: date,
      );

      // Cache today's steps if this is for today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entryDate = DateTime(
        result.date.year,
        result.date.month,
        result.date.day,
      );

      if (entryDate.isAtSameMomentAs(today)) {
        await localDataSource.cacheTodaySteps(result.steps);
      }

      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getTodaySteps() async {
    try {
      final steps = await remoteDataSource.getTodaySteps();
      await localDataSource.cacheTodaySteps(steps);
      return Right(steps);
    } catch (e) {
      // Try to get from cache
      final cachedSteps = await localDataSource.getCachedTodaySteps();
      if (cachedSteps != null) {
        return Right(cachedSteps);
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StepEntry>>> getStepsHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final entries = await remoteDataSource.getStepsHistory(
        startDate: startDate,
        endDate: endDate,
      );

      await localDataSource.cacheStepsHistory(entries);

      return Right(entries.map((model) => model.toEntity()).toList());
    } catch (e) {
      // Try to get from cache
      final cachedEntries = await localDataSource.getCachedStepsHistory();
      if (cachedEntries != null) {
        return Right(cachedEntries.map((model) => model.toEntity()).toList());
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
