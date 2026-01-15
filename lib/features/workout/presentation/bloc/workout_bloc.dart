import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/workout_log.dart';
import '../../domain/repositories/workout_repository.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository repository;

  WorkoutBloc({required this.repository}) : super(const WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<LoadWorkoutById>(_onLoadWorkoutById);
    on<CreateWorkout>(_onCreateWorkout);
    on<UpdateWorkout>(_onUpdateWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
    on<CompleteWorkout>(_onCompleteWorkout);
  }

  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    print('=== WORKOUT BLOC: LOAD WORKOUTS ===');
    emit(const WorkoutLoading());

    print('Calling repository.getWorkouts...');
    final result = await repository.getWorkouts();

    result.fold(
      (failure) {
        print('ERROR: ${failure.message}');
        emit(WorkoutError(failure.message));
      },
      (workouts) {
        print('SUCCESS: Loaded ${workouts.length} workouts');
        emit(WorkoutListLoaded(workouts));
      },
    );
  }

  Future<void> _onLoadWorkoutById(
    LoadWorkoutById event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    final result = await repository.getWorkoutById(event.id);

    result.fold(
      (failure) => emit(WorkoutError(failure.message)),
      (workout) => emit(WorkoutDetailLoaded(workout)),
    );
  }

  Future<void> _onCreateWorkout(
    CreateWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    print('=== WORKOUT BLOC: CREATE WORKOUT ===');
    print('Workout data: ${event.workout.name}');
    print('Exercises count: ${event.workout.exercises.length}');
    
    emit(const WorkoutLoading());

    print('Calling repository.createWorkout...');
    final result = await repository.createWorkout(event.workout);

    result.fold(
      (failure) {
        print('ERROR: ${failure.message}');
        emit(WorkoutError(failure.message));
      },
      (_) {
        print('SUCCESS: Workout created');
        emit(const WorkoutOperationSuccess('Antrenman programı oluşturuldu'));
      },
    );
  }

  Future<void> _onUpdateWorkout(
    UpdateWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    final result = await repository.updateWorkout(event.id, event.workout);

    result.fold(
      (failure) => emit(WorkoutError(failure.message)),
      (_) => emit(const WorkoutOperationSuccess('Antrenman programı güncellendi')),
    );
  }

  Future<void> _onDeleteWorkout(
    DeleteWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    final result = await repository.deleteWorkout(event.id);

    result.fold(
      (failure) => emit(WorkoutError(failure.message)),
      (_) => emit(const WorkoutOperationSuccess('Antrenman programı silindi')),
    );
  }

  Future<void> _onCompleteWorkout(
    CompleteWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());

    final log = WorkoutLog(
      id: '',
      userId: '',
      workoutId: event.workoutId,
      date: DateTime.now(),
      duration: event.duration,
      notes: event.notes,
      completed: true,
      createdAt: DateTime.now(),
    );

    final result = await repository.createWorkoutLog(log);

    result.fold(
      (failure) => emit(WorkoutError(failure.message)),
      (createdLog) => emit(WorkoutCompleted(createdLog)),
    );
  }
}
