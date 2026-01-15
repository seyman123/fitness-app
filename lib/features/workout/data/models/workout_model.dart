import '../../domain/entities/workout.dart';
import 'workout_exercise_model.dart';

class WorkoutModel extends Workout {
  const WorkoutModel({
    required super.id,
    required super.userId,
    required super.name,
    super.description,
    required super.isTemplate,
    required super.exercises,
    super.exerciseCount,
    super.completedCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    final exercisesList = json['exercises'] as List<dynamic>?;
    final exercises = exercisesList
            ?.map((e) => WorkoutExerciseModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WorkoutModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isTemplate: json['isTemplate'] as bool? ?? false,
      exercises: exercises,
      exerciseCount: json['exerciseCount'] as int?,
      completedCount: json['completedCount'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'isTemplate': isTemplate,
      'exercises': exercises
          .map((e) => (e as WorkoutExerciseModel).toCreateJson())
          .toList(),
    };
  }
}
