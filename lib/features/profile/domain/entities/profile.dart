import 'package:equatable/equatable.dart';

/// Profile entity - Domain layer
/// Represents user's fitness profile with health metrics
class Profile extends Equatable {
  final String id;
  final String userId;
  final int age;
  final String gender; // 'male' or 'female'
  final double height; // in cm
  final double weight; // in kg
  final double activityLevel; // 1.2, 1.375, 1.55, 1.725, 1.9
  final double? goalWeight; // Optional weight goal
  final String? goalType; // LOSE_WEIGHT, GAIN_WEIGHT, BUILD_MUSCLE, MAINTAIN, GET_FIT
  final DateTime createdAt;
  final DateTime updatedAt;

  // Calculated values (from backend)
  final double? bmi;
  final String? bmiCategory;
  final int? dailyCalories;

  const Profile({
    required this.id,
    required this.userId,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.goalWeight,
    this.goalType,
    required this.createdAt,
    required this.updatedAt,
    this.bmi,
    this.bmiCategory,
    this.dailyCalories,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        age,
        gender,
        height,
        weight,
        activityLevel,
        goalWeight,
        goalType,
        createdAt,
        updatedAt,
        bmi,
        bmiCategory,
        dailyCalories,
      ];

  /// Get activity level description
  String get activityLevelDescription {
    if (activityLevel <= 1.2) return 'Hareketsiz (ofis işi)';
    if (activityLevel <= 1.375) return 'Az hareketli (haftada 1-3 gün)';
    if (activityLevel <= 1.55) return 'Orta (haftada 3-5 gün)';
    if (activityLevel <= 1.725) return 'Çok aktif (haftada 6-7 gün)';
    return 'Ekstra aktif (günde 2 kez)';
  }

  /// Check if user has a weight goal
  bool get hasWeightGoal => goalWeight != null;

  /// Calculate remaining weight to target
  double? get remainingWeightToTarget {
    if (goalWeight == null) return null;
    return weight - goalWeight!;
  }
}
