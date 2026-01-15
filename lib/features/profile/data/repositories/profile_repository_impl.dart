import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

/// Profile repository implementation
/// Coordinates between remote and local data sources
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Profile>> createProfile({
    required int age,
    required String gender,
    required double height,
    required double weight,
    required double activityLevel,
    double? goalWeight,
    String? goalType,
  }) async {
    try {
      // Create profile on backend
      final profileModel = await remoteDataSource.createProfile(
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        activityLevel: activityLevel,
        goalWeight: goalWeight,
        goalType: goalType,
      );

      // Cache profile locally
      await localDataSource.cacheProfile(profileModel);

      return Right(profileModel);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Profil oluşturulamadı: $e'));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    try {
      // Try to get from cache first
      final cachedProfile = await localDataSource.getCachedProfile();
      if (cachedProfile != null) {
        return Right(cachedProfile);
      }

      // If not in cache, fetch from backend
      final profileModel = await remoteDataSource.getProfile();

      // Cache for next time
      await localDataSource.cacheProfile(profileModel);

      return Right(profileModel);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } on CacheFailure {
      // If cache fails, try remote anyway
      try {
        final profileModel = await remoteDataSource.getProfile();
        await localDataSource.cacheProfile(profileModel);
        return Right(profileModel);
      } catch (e) {
        return Left(ServerFailure('Profil bilgileri alınamadı: $e'));
      }
    } catch (e) {
      return Left(ServerFailure('Profil bilgileri alınamadı: $e'));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? activityLevel,
    double? goalWeight,
    String? goalType,
  }) async {
    try {
      // Update on backend
      final profileModel = await remoteDataSource.updateProfile(
        age: age,
        gender: gender,
        height: height,
        weight: weight,
        activityLevel: activityLevel,
        goalWeight: goalWeight,
        goalType: goalType,
      );

      // Update cache
      await localDataSource.cacheProfile(profileModel);

      return Right(profileModel);
    } on ServerFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Profil güncellenemedi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocalProfile() async {
    try {
      await localDataSource.clearProfile();
      return const Right(null);
    } on CacheFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(CacheFailure('Profil silinemedi: $e'));
    }
  }
}
