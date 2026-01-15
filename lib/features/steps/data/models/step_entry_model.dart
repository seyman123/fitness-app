import '../../domain/entities/step_entry.dart';

class StepEntryModel extends StepEntry {
  const StepEntryModel({
    required super.id,
    required super.userId,
    required super.steps,
    required super.date,
    required super.createdAt,
  });

  factory StepEntryModel.fromJson(Map<String, dynamic> json) {
    return StepEntryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      steps: json['steps'] as int,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'steps': steps,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  StepEntry toEntity() {
    return StepEntry(
      id: id,
      userId: userId,
      steps: steps,
      date: date,
      createdAt: createdAt,
    );
  }

  factory StepEntryModel.fromEntity(StepEntry entity) {
    return StepEntryModel(
      id: entity.id,
      userId: entity.userId,
      steps: entity.steps,
      date: entity.date,
      createdAt: entity.createdAt,
    );
  }
}
