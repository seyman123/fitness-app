import 'package:equatable/equatable.dart';
import '../../domain/entities/water_entry.dart';

/// Water entry model with JSON serialization
class WaterEntryModel extends Equatable {
  final String id;
  final String userId;
  final int amount;
  final DateTime date;
  final DateTime createdAt;

  const WaterEntryModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.createdAt,
  });

  /// Create from JSON
  factory WaterEntryModel.fromJson(Map<String, dynamic> json) {
    return WaterEntryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: json['amount'] as int,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to entity
  WaterEntry toEntity() {
    return WaterEntry(
      id: id,
      userId: userId,
      amount: amount,
      date: date,
      createdAt: createdAt,
    );
  }

  /// Create from entity
  factory WaterEntryModel.fromEntity(WaterEntry entry) {
    return WaterEntryModel(
      id: entry.id,
      userId: entry.userId,
      amount: entry.amount,
      date: entry.date,
      createdAt: entry.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, amount, date, createdAt];
}
