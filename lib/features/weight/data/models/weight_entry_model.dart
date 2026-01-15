import '../../domain/entities/weight_entry.dart';

class WeightEntryModel extends WeightEntry {
  const WeightEntryModel({
    required super.id,
    required super.weight,
    super.bmi,
    super.notes,
    required super.date,
    required super.createdAt,
  });

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) {
    return WeightEntryModel(
      id: json['id'],
      weight: (json['weight'] as num).toDouble(),
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      notes: json['notes'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'bmi': bmi,
      'notes': notes,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WeightEntry toEntity() {
    return WeightEntry(
      id: id,
      weight: weight,
      bmi: bmi,
      notes: notes,
      date: date,
      createdAt: createdAt,
    );
  }
}
