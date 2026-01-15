import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  final String id;
  final double weight; // kg
  final double? bmi;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  const WeightEntry({
    required this.id,
    required this.weight,
    this.bmi,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, weight, bmi, notes, date, createdAt];
}
