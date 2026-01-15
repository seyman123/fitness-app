import 'package:equatable/equatable.dart';

class NutritionLog extends Equatable {
  final String id;
  final String userId;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String foodName;
  final double calories;
  final double? protein; // gram
  final double? carbs; // gram
  final double? fat; // gram
  final DateTime date;
  final DateTime createdAt;

  const NutritionLog({
    required this.id,
    required this.userId,
    required this.mealType,
    required this.foodName,
    required this.calories,
    this.protein,
    this.carbs,
    this.fat,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        mealType,
        foodName,
        calories,
        protein,
        carbs,
        fat,
        date,
        createdAt,
      ];

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'Kahvaltı';
      case 'lunch':
        return 'Öğle Yemeği';
      case 'dinner':
        return 'Akşam Yemeği';
      case 'snack':
        return 'Atıştırmalık';
      default:
        return mealType;
    }
  }
}
