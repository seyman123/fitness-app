import 'weight_entry_model.dart';

class WeightResponseModel {
  final List<WeightEntryModel> history;

  const WeightResponseModel({required this.history});

  factory WeightResponseModel.fromJson(Map<String, dynamic> json) {
    return WeightResponseModel(
      history: (json['history'] as List)
          .map((e) => WeightEntryModel.fromJson(e))
          .toList(),
    );
  }
}

class WeightStatsModel {
  final double? currentWeight;
  final double? startWeight;
  final double weightChange;
  final String trend; // 'GAINING', 'LOSING', 'STABLE'
  final List<WeightDataPoint> history;

  const WeightStatsModel({
    this.currentWeight,
    this.startWeight,
    required this.weightChange,
    required this.trend,
    required this.history,
  });

  factory WeightStatsModel.fromJson(Map<String, dynamic> json) {
    return WeightStatsModel(
      currentWeight: json['currentWeight'] != null
          ? (json['currentWeight'] as num).toDouble()
          : null,
      startWeight: json['startWeight'] != null
          ? (json['startWeight'] as num).toDouble()
          : null,
      weightChange: (json['weightChange'] as num).toDouble(),
      trend: json['trend'],
      history: (json['history'] as List)
          .map((e) => WeightDataPoint.fromJson(e))
          .toList(),
    );
  }
}

class WeightDataPoint {
  final DateTime date;
  final double weight;
  final double? bmi;

  const WeightDataPoint({
    required this.date,
    required this.weight,
    this.bmi,
  });

  factory WeightDataPoint.fromJson(Map<String, dynamic> json) {
    return WeightDataPoint(
      date: DateTime.parse(json['date']),
      weight: (json['weight'] as num).toDouble(),
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
    );
  }
}
