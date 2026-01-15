import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/repositories/weight_repository.dart';
import '../datasources/weight_remote_data_source.dart';
import '../models/weight_response_model.dart';

class WeightRepositoryImpl implements WeightRepository {
  final WeightRemoteDataSource remoteDataSource;

  WeightRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WeightEntry>> createWeightEntry({
    required double weight,
    double? bmi,
    String? notes,
    DateTime? date,
  }) async {
    try {
      final result = await remoteDataSource.createWeightEntry(
        weight: weight,
        bmi: bmi,
        notes: notes,
        date: date,
      );
      return Right(result.toEntity());
    } on ServerException {
      return Left(ServerFailure('Kilo kaydı oluşturulamadı'));
    }
  }

  @override
  Future<Either<Failure, List<WeightEntry>>> getWeightHistory({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await remoteDataSource.getWeightHistory(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure('Kilo geçmişi alınamadı'));
    }
  }

  @override
  Future<Either<Failure, WeightStatsModel>> getWeightStats({int days = 30}) async {
    try {
      final result = await remoteDataSource.getWeightStats(days: days);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure('İstatistikler alınamadı'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWeightEntry(String id) async {
    try {
      await remoteDataSource.deleteWeightEntry(id);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure('Kilo kaydı silinemedi'));
    }
  }
}
