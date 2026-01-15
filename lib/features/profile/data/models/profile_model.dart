import '../../domain/entities/profile.dart';

/// Profile model - Data layer
/// Handles JSON serialization/deserialization
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.userId,
    required super.age,
    required super.gender,
    required super.height,
    required super.weight,
    required super.activityLevel,
    super.goalWeight,
    super.goalType,
    required super.createdAt,
    required super.updatedAt,
    super.bmi,
    super.bmiCategory,
    super.dailyCalories,
  });

  /// Create ProfileModel from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      activityLevel: (json['activityLevel'] as num).toDouble(),
      goalWeight: json['goalWeight'] != null
          ? (json['goalWeight'] as num).toDouble()
          : null,
      goalType: json['goalType'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      bmiCategory: json['bmiCategory'] as String?,
      dailyCalories: json['dailyCalories'] as int?,
    );
  }

  /// Convert ProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'goalWeight': goalWeight,
      'goalType': goalType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'dailyCalories': dailyCalories,
    };
  }

  /// Convert Profile entity to ProfileModel
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      age: profile.age,
      gender: profile.gender,
      height: profile.height,
      weight: profile.weight,
      activityLevel: profile.activityLevel,
      goalWeight: profile.goalWeight,
      goalType: profile.goalType,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
      bmi: profile.bmi,
      bmiCategory: profile.bmiCategory,
      dailyCalories: profile.dailyCalories,
    );
  }

  /// Create a copy with updated fields
  ProfileModel copyWith({
    String? id,
    String? userId,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? activityLevel,
    double? goalWeight,
    String? goalType,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? bmi,
    String? bmiCategory,
    int? dailyCalories,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      goalWeight: goalWeight ?? this.goalWeight,
      goalType: goalType ?? this.goalType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bmi: bmi ?? this.bmi,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      dailyCalories: dailyCalories ?? this.dailyCalories,
    );
  }
}
