import 'package:equatable/equatable.dart';

abstract class NutritionEvent extends Equatable {
  const NutritionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayNutrition extends NutritionEvent {
  const LoadTodayNutrition();
}

class AddNutritionLog extends NutritionEvent {
  final String mealType;
  final String foodName;
  final double calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  const AddNutritionLog({
    required this.mealType,
    required this.foodName,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  @override
  List<Object?> get props => [mealType, foodName, calories, protein, carbs, fat];
}

class DeleteNutritionLog extends NutritionEvent {
  final String id;

  const DeleteNutritionLog(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadNutritionHistory extends NutritionEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? mealType;

  const LoadNutritionHistory({
    this.startDate,
    this.endDate,
    this.mealType,
  });

  @override
  List<Object?> get props => [startDate, endDate, mealType];
}

class RefreshNutrition extends NutritionEvent {
  const RefreshNutrition();
}
