import 'package:equatable/equatable.dart';

class WorkoutExercise extends Equatable {
  final String id;
  final String workoutId;
  final String name;
  final int sets;
  final int reps;
  final int? restSeconds;
  final String? notes;
  final int order;
  final DateTime createdAt;

  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.notes,
    required this.order,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        workoutId,
        name,
        sets,
        reps,
        restSeconds,
        notes,
        order,
        createdAt,
      ];
}
