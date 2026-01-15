import '../../domain/entities/workout_log.dart';
import 'workout_model.dart';

class WorkoutLogModel extends WorkoutLog {
  const WorkoutLogModel({
    required super.id,
    required super.userId,
    required super.workoutId,
    required super.date,
    super.duration,
    super.notes,
    required super.completed,
    super.workout,
    required super.createdAt,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      workoutId: json['workoutId'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: json['duration'] as int?,
      notes: json['notes'] as String?,
      completed: json['completed'] as bool? ?? true,
      workout: json['workout'] != null
          ? WorkoutModel.fromJson(json['workout'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutId': workoutId,
      'date': date.toIso8601String(),
      if (duration != null) 'duration': duration,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'completed': completed,
    };
  }
}
