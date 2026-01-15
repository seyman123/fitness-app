import 'package:equatable/equatable.dart';
import '../../domain/entities/nutrition_log.dart';

abstract class NutritionState extends Equatable {
  const NutritionState();

  @override
  List<Object?> get props => [];
}

class NutritionInitial extends NutritionState {
  const NutritionInitial();
}

class NutritionLoading extends NutritionState {
  const NutritionLoading();
}

class NutritionLoaded extends NutritionState {
  final List<NutritionLog> logs;
  final Map<String, double> totals;
  final int count;
  final Map<String, List<NutritionLog>>? byMealType;

  const NutritionLoaded({
    required this.logs,
    required this.totals,
    required this.count,
    this.byMealType,
  });

  @override
  List<Object?> get props => [logs, totals, count, byMealType];

  double get totalCalories => totals['calories'] ?? 0.0;
  double get totalProtein => totals['protein'] ?? 0.0;
  double get totalCarbs => totals['carbs'] ?? 0.0;
  double get totalFat => totals['fat'] ?? 0.0;
}

class NutritionOperationSuccess extends NutritionState {
  final String message;

  const NutritionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class NutritionError extends NutritionState {
  final String message;

  const NutritionError(this.message);

  @override
  List<Object?> get props => [message];
}
