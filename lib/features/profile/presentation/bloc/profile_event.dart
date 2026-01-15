import 'package:equatable/equatable.dart';

/// Profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load profile from cache or backend
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Create new profile
class CreateProfile extends ProfileEvent {
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double activityLevel;
  final double? goalWeight;
  final String? goalType;

  const CreateProfile({
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.goalWeight,
    this.goalType,
  });

  @override
  List<Object?> get props => [
        age,
        gender,
        height,
        weight,
        activityLevel,
        goalWeight,
        goalType,
      ];
}

/// Update existing profile
class UpdateProfile extends ProfileEvent {
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final double? activityLevel;
  final double? goalWeight;
  final String? goalType;

  const UpdateProfile({
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.activityLevel,
    this.goalWeight,
    this.goalType,
  });

  @override
  List<Object?> get props => [
        age,
        gender,
        height,
        weight,
        activityLevel,
        goalWeight,
        goalType,
      ];
}

/// Delete local profile cache
class DeleteProfile extends ProfileEvent {
  const DeleteProfile();
}

/// Refresh profile from backend
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}
