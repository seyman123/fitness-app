import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile.dart';

/// Profile repository interface - Domain layer
/// Defines contract for profile data operations
abstract class ProfileRepository {
  /// Create a new profile
  /// Returns Either<Failure, Profile>
  Future<Either<Failure, Profile>> createProfile({
    required int age,
    required String gender,
    required double height,
    required double weight,
    required double activityLevel,
    double? goalWeight,
    String? goalType,
  });

  /// Get current user's profile
  /// Returns Either<Failure, Profile>
  Future<Either<Failure, Profile>> getProfile();

  /// Update existing profile
  /// Returns Either<Failure, Profile>
  Future<Either<Failure, Profile>> updateProfile({
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? activityLevel,
    double? goalWeight,
    String? goalType,
  });

  /// Delete profile (clear local cache)
  Future<Either<Failure, void>> deleteLocalProfile();
}
