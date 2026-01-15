import 'package:equatable/equatable.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_log.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {
  const WorkoutInitial();
}

class WorkoutLoading extends WorkoutState {
  const WorkoutLoading();
}

class WorkoutListLoaded extends WorkoutState {
  final List<Workout> workouts;

  const WorkoutListLoaded(this.workouts);

  @override
  List<Object> get props => [workouts];
}

class WorkoutDetailLoaded extends WorkoutState {
  final Workout workout;

  const WorkoutDetailLoaded(this.workout);

  @override
  List<Object> get props => [workout];
}

class WorkoutOperationSuccess extends WorkoutState {
  final String message;

  const WorkoutOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class WorkoutCompleted extends WorkoutState {
  final WorkoutLog log;

  const WorkoutCompleted(this.log);

  @override
  List<Object> get props => [log];
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  List<Object> get props => [message];
}
