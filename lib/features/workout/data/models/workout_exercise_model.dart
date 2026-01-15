import '../../domain/entities/workout_exercise.dart';

class WorkoutExerciseModel extends WorkoutExercise {
  const WorkoutExerciseModel({
    required super.id,
    required super.workoutId,
    required super.name,
    required super.sets,
    required super.reps,
    super.restSeconds,
    super.notes,
    required super.order,
    required super.createdAt,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      restSeconds: json['restSeconds'] as int?,
      notes: json['notes'] as String?,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory WorkoutExerciseModel.fromEntity(WorkoutExercise exercise) {
    return WorkoutExerciseModel(
      id: exercise.id,
      workoutId: exercise.workoutId,
      name: exercise.name,
      sets: exercise.sets,
      reps: exercise.reps,
      restSeconds: exercise.restSeconds,
      notes: exercise.notes,
      order: exercise.order,
      createdAt: exercise.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      if (restSeconds != null) 'restSeconds': restSeconds,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'order': order,
    };
  }

  // For creating new exercises (without id)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      if (restSeconds != null) 'restSeconds': restSeconds,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'order': order,
    };
  }
}
