import 'package:equatable/equatable.dart';

/// Water tracking entry entity
class WaterEntry extends Equatable {
  final String id;
  final String userId;
  final int amount; // ml
  final DateTime date;
  final DateTime createdAt;

  const WaterEntry({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, amount, date, createdAt];
}
