import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/workout.dart';
import '../entities/workout_log.dart';

abstract class WorkoutRepository {
  Future<Either<Failure, List<Workout>>> getWorkouts();
  Future<Either<Failure, Workout>> getWorkoutById(String id);
  Future<Either<Failure, Workout>> createWorkout(Workout workout);
  Future<Either<Failure, Workout>> updateWorkout(String id, Workout workout);
  Future<Either<Failure, void>> deleteWorkout(String id);
  Future<Either<Failure, List<WorkoutLog>>> getWorkoutLogs({
    String? workoutId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, WorkoutLog>> createWorkoutLog(WorkoutLog log);
  Future<Either<Failure, void>> deleteWorkoutLog(String id);
}
