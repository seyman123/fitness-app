import 'package:equatable/equatable.dart';
import 'workout.dart';

class WorkoutLog extends Equatable {
  final String id;
  final String userId;
  final String workoutId;
  final DateTime date;
  final int? duration;
  final String? notes;
  final bool completed;
  final Workout? workout;
  final DateTime createdAt;

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.date,
    this.duration,
    this.notes,
    required this.completed,
    this.workout,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        workoutId,
        date,
        duration,
        notes,
        completed,
        workout,
        createdAt,
      ];
}
