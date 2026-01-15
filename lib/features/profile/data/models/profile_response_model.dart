import 'profile_model.dart';

/// Profile response model from backend API
/// Wraps profile data with calculations (BMI, calories)
class ProfileResponseModel {
  final ProfileModel profile;
  final ProfileCalculations? calculations;

  const ProfileResponseModel({
    required this.profile,
    this.calculations,
  });

  /// Create from JSON response
  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      profile: ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
      calculations: json['calculations'] != null
          ? ProfileCalculations.fromJson(
              json['calculations'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Merge calculations into profile model
  ProfileModel get profileWithCalculations {
    if (calculations == null) return profile;

    return profile.copyWith(
      bmi: calculations!.bmi,
      bmiCategory: calculations!.bmiCategory,
      dailyCalories: calculations!.dailyCalories,
    );
  }
}

/// Profile calculations from backend
class ProfileCalculations {
  final double bmi;
  final String bmiCategory;
  final int dailyCalories;

  const ProfileCalculations({
    required this.bmi,
    required this.bmiCategory,
    required this.dailyCalories,
  });

  factory ProfileCalculations.fromJson(Map<String, dynamic> json) {
    return ProfileCalculations(
      bmi: (json['bmi'] as num).toDouble(),
      bmiCategory: json['bmiCategory'] as String,
      dailyCalories: json['dailyCalories'] as int,
    );
  }
}
