import 'package:equatable/equatable.dart';
import 'water_entry_model.dart';

/// Water response model from backend
class WaterResponseModel extends Equatable {
  final List<WaterEntryModel> entries;
  final int total;
  final int count;

  const WaterResponseModel({
    required this.entries,
    required this.total,
    required this.count,
  });

  factory WaterResponseModel.fromJson(Map<String, dynamic> json) {
    return WaterResponseModel(
      entries: (json['entries'] as List)
          .map((e) => WaterEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'total': total,
      'count': count,
    };
  }

  @override
  List<Object?> get props => [entries, total, count];
}
