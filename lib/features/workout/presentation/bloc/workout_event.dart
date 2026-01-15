import 'package:equatable/equatable.dart';
import '../../domain/entities/workout.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkouts extends WorkoutEvent {
  const LoadWorkouts();
}

class LoadWorkoutById extends WorkoutEvent {
  final String id;

  const LoadWorkoutById(this.id);

  @override
  List<Object> get props => [id];
}

class CreateWorkout extends WorkoutEvent {
  final Workout workout;

  const CreateWorkout(this.workout);

  @override
  List<Object> get props => [workout];
}

class UpdateWorkout extends WorkoutEvent {
  final String id;
  final Workout workout;

  const UpdateWorkout(this.id, this.workout);

  @override
  List<Object> get props => [id, workout];
}

class DeleteWorkout extends WorkoutEvent {
  final String id;

  const DeleteWorkout(this.id);

  @override
  List<Object> get props => [id];
}

class CompleteWorkout extends WorkoutEvent {
  final String workoutId;
  final int? duration;
  final String? notes;

  const CompleteWorkout({
    required this.workoutId,
    this.duration,
    this.notes,
  });

  @override
  List<Object?> get props => [workoutId, duration, notes];
}
