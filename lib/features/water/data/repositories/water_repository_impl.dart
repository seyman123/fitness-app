import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/repositories/water_repository.dart';
import '../datasources/water_local_data_source.dart';
import '../datasources/water_remote_data_source.dart';

class WaterRepositoryImpl implements WaterRepository {
  final WaterRemoteDataSource remoteDataSource;
  final WaterLocalDataSource localDataSource;

  WaterRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, WaterEntry>> addWaterEntry(int amount) async {
    try {
      final entryModel = await remoteDataSource.addWaterEntry(amount);
      return Right(entryModel.toEntity());
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Su kaydı eklenemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaterEntry>>> getTodayWater() async {
    try {
      final response = await remoteDataSource.getTodayWater();

      // Cache entries
      await localDataSource.cacheWaterEntries(response.entries);

      return Right(response.entries.map((e) => e.toEntity()).toList());
    } on ServerFailure catch (failure) {
      // Try to get from cache
      try {
        final cached = await localDataSource.getCachedWaterEntries();
        if (cached != null) {
          return Right(cached.map((e) => e.toEntity()).toList());
        }
      } catch (_) {}

      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Günlük su kaydı alınamadı: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaterEntry>>> getWaterEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await remoteDataSource.getWaterEntries(
        startDate: startDate,
        endDate: endDate,
      );

      return Right(response.entries.map((e) => e.toEntity()).toList());
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Su kayıtları alınamadı: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWaterEntry(String id) async {
    try {
      await remoteDataSource.deleteWaterEntry(id);
      return const Right(null);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Su kaydı silinemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTodayTotal() async {
    try {
      final response = await remoteDataSource.getTodayWater();
      return Right(response.total);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Günlük toplam alınamadı: $e'));
    }
  }
}
