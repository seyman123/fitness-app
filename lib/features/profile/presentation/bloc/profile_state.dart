import 'package:equatable/equatable.dart';
import '../../domain/entities/profile.dart';

/// Profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state - No profile loaded yet
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state - Profile operation in progress
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Loaded state - Profile successfully loaded
class ProfileLoaded extends ProfileState {
  final Profile profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Empty state - User has no profile yet
class ProfileEmpty extends ProfileState {
  const ProfileEmpty();
}

/// Error state - Profile operation failed
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Success state - Profile created/updated successfully (transient state)
class ProfileOperationSuccess extends ProfileState {
  final Profile profile;
  final String message;

  const ProfileOperationSuccess({
    required this.profile,
    required this.message,
  });

  @override
  List<Object?> get props => [profile, message];
}
