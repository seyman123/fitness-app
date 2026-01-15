import 'package:equatable/equatable.dart';
import 'workout_exercise.dart';

class Workout extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isTemplate;
  final List<WorkoutExercise> exercises;
  final int? exerciseCount;
  final int? completedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.isTemplate,
    required this.exercises,
    this.exerciseCount,
    this.completedCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        isTemplate,
        exercises,
        exerciseCount,
        completedCount,
        createdAt,
        updatedAt,
      ];
}
