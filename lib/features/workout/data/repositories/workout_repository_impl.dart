import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_log.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_remote_data_source.dart';
import '../models/workout_model.dart';
import '../models/workout_exercise_model.dart';
import '../models/workout_log_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource remoteDataSource;

  WorkoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Workout>>> getWorkouts() async {
    try {
      final workouts = await remoteDataSource.getWorkouts();
      return Right(workouts);
    } on ServerException {
      return const Left(ServerFailure('Antrenman programları alınamadı'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }

  @override
  Future<Either<Failure, Workout>> getWorkoutById(String id) async {
    try {
      final workout = await remoteDataSource.getWorkoutById(id);
      return Right(workout);
    } on NotFoundException {
      return const Left(ServerFailure('Antrenman programı bulunamadı'));
    } on ServerException {
      return const Left(ServerFailure('Antrenman programı alınamadı'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }

  @override
  Future<Either<Failure, Workout>> createWorkout(Workout workout) async {
    try {
      final workoutModel = WorkoutModel(
        id: workout.id,
        userId: workout.userId,
        name: workout.name,
        description: workout.description,
        isTemplate: workout.isTemplate,
        exercises: workout.exercises.map((e) => WorkoutExerciseModel.fromEntity(e)).toList(),
        createdAt: workout.createdAt,
        updatedAt: workout.updatedAt,
      );

      final createdWorkout = await remoteDataSource.createWorkout(workoutModel);
      return Right(createdWorkout);
    } on ServerException {
      return const Left(ServerFailure('Antrenman programı oluşturulamadı'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }

  @override
  Future<Either<Failure, Workout>> updateWorkout(String id, Workout workout) async {
    try {
      final workoutModel = WorkoutModel(
        id: workout.id,
        userId: workout.userId,
        name: workout.name,
        description: workout.description,
        isTemplate: workout.isTemplate,
        exercises: workout.exercises.map((e) => WorkoutExerciseModel.fromEntity(e)).toList(),
        createdAt: workout.createdAt,
        updatedAt: workout.updatedAt,
      );

      final updatedWorkout = await remoteDataSource.updateWorkout(id, workoutModel);
      return Right(updatedWorkout);
    } on NotFoundException {
      return const Left(ServerFailure('Antrenman programı bulunamadı'));
    } on ServerException {
      return const Left(ServerFailure('Antrenman programı güncellenemedi'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkout(String id) async {
    try {
      await remoteDataSource.deleteWorkout(id);
      return const Right(null);
    } on NotFoundException {
      return const Left(ServerFailure('Antrenman programı bulunamadı'));
    } on ServerException {
      return const Left(ServerFailure('Antrenman programı silinemedi'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutLog>>> getWorkoutLogs({
    String? workoutId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final logs = await remoteDataSource.getWorkoutLogs(
        workoutId: workoutId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(logs);
    } on ServerException {
      return const Left(ServerFailure('Antrenman kayıtları alınamadı'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkoutLog>> createWorkoutLog(WorkoutLog log) async {
    try {
      final logModel = WorkoutLogModel(
        id: log.id,
        userId: log.userId,
        workoutId: log.workoutId,
        date: log.date,
        duration: log.duration,
        notes: log.notes,
        completed: log.completed,
        createdAt: log.createdAt,
      );

      final createdLog = await remoteDataSource.createWorkoutLog(logModel);
      return Right(createdLog);
    } on ServerException {
      return const Left(ServerFailure('Antrenman kaydı oluşturulamadı'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkoutLog(String id) async {
    try {
      await remoteDataSource.deleteWorkoutLog(id);
      return const Right(null);
    } on NotFoundException {
      return const Left(ServerFailure('Antrenman kaydı bulunamadı'));
    } on ServerException {
      return const Left(ServerFailure('Antrenman kaydı silinemedi'));
    } catch (e) {
      return Left(ServerFailure('Beklenmeyen hata: $e'));
    }
  }
}
