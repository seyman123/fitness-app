import '../../domain/entities/nutrition_log.dart';

class NutritionLogModel extends NutritionLog {
  const NutritionLogModel({
    required super.id,
    required super.userId,
    required super.mealType,
    required super.foodName,
    required super.calories,
    super.protein,
    super.carbs,
    super.fat,
    required super.date,
    required super.createdAt,
  });

  factory NutritionLogModel.fromJson(Map<String, dynamic> json) {
    return NutritionLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mealType: json['mealType'] as String,
      foodName: json['foodName'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: json['protein'] != null ? (json['protein'] as num).toDouble() : null,
      carbs: json['carbs'] != null ? (json['carbs'] as num).toDouble() : null,
      fat: json['fat'] != null ? (json['fat'] as num).toDouble() : null,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NutritionLog toEntity() {
    return NutritionLog(
      id: id,
      userId: userId,
      mealType: mealType,
      foodName: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      date: date,
      createdAt: createdAt,
    );
  }

  factory NutritionLogModel.fromEntity(NutritionLog log) {
    return NutritionLogModel(
      id: log.id,
      userId: log.userId,
      mealType: log.mealType,
      foodName: log.foodName,
      calories: log.calories,
      protein: log.protein,
      carbs: log.carbs,
      fat: log.fat,
      date: log.date,
      createdAt: log.createdAt,
    );
  }
}
