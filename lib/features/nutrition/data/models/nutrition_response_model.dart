import 'package:equatable/equatable.dart';
import 'nutrition_log_model.dart';

class NutritionResponseModel extends Equatable {
  final List<NutritionLogModel> logs;
  final Map<String, double> totals;
  final int count;
  final Map<String, List<NutritionLogModel>>? byMealType;

  const NutritionResponseModel({
    required this.logs,
    required this.totals,
    required this.count,
    this.byMealType,
  });

  factory NutritionResponseModel.fromJson(Map<String, dynamic> json) {
    final logsData = json['logs'] as List<dynamic>;
    final logs = logsData.map((e) => NutritionLogModel.fromJson(e as Map<String, dynamic>)).toList();

    final totalsData = json['totals'] as Map<String, dynamic>;
    final totals = {
      'calories': (totalsData['calories'] as num).toDouble(),
      'protein': (totalsData['protein'] as num).toDouble(),
      'carbs': (totalsData['carbs'] as num).toDouble(),
      'fat': (totalsData['fat'] as num).toDouble(),
    };

    Map<String, List<NutritionLogModel>>? byMealType;
    if (json['byMealType'] != null) {
      final byMealTypeData = json['byMealType'] as Map<String, dynamic>;
      byMealType = {
        'breakfast': (byMealTypeData['breakfast'] as List<dynamic>)
            .map((e) => NutritionLogModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        'lunch': (byMealTypeData['lunch'] as List<dynamic>)
            .map((e) => NutritionLogModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        'dinner': (byMealTypeData['dinner'] as List<dynamic>)
            .map((e) => NutritionLogModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        'snack': (byMealTypeData['snack'] as List<dynamic>)
            .map((e) => NutritionLogModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      };
    }

    return NutritionResponseModel(
      logs: logs,
      totals: totals,
      count: json['count'] as int,
      byMealType: byMealType,
    );
  }

  @override
  List<Object?> get props => [logs, totals, count, byMealType];
}
