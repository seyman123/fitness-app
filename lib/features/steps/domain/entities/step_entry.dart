import 'package:equatable/equatable.dart';

class StepEntry extends Equatable {
  final String id;
  final String userId;
  final int steps;
  final DateTime date;
  final DateTime createdAt;

  const StepEntry({
    required this.id,
    required this.userId,
    required this.steps,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, steps, date, createdAt];
}
