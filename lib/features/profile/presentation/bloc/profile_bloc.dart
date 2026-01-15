import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Profile BLoC
/// Manages profile state and business logic
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<CreateProfile>(_onCreateProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<DeleteProfile>(_onDeleteProfile);
    on<RefreshProfile>(_onRefreshProfile);
  }

  /// Load profile (from cache or backend)
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.getProfile();

    result.fold(
      (failure) {
        // If profile doesn't exist, emit empty state
        if (failure.message.contains('404') ||
            failure.message.contains('not found') ||
            failure.message.contains('bulunamadı') ||
            failure.message.contains('Profil bulunamadı')) {
          emit(const ProfileEmpty());
        } else {
          emit(ProfileError(message: failure.message));
        }
      },
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  /// Create new profile
  Future<void> _onCreateProfile(
    CreateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.createProfile(
      age: event.age,
      gender: event.gender,
      height: event.height,
      weight: event.weight,
      activityLevel: event.activityLevel,
      goalWeight: event.goalWeight,
      goalType: event.goalType,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) {
        emit(ProfileOperationSuccess(
          profile: profile,
          message: 'Profil başarıyla oluşturuldu',
        ));
        // Immediately transition to loaded state
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  /// Update existing profile
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.updateProfile(
      age: event.age,
      gender: event.gender,
      height: event.height,
      weight: event.weight,
      activityLevel: event.activityLevel,
      goalWeight: event.goalWeight,
      goalType: event.goalType,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) {
        emit(ProfileOperationSuccess(
          profile: profile,
          message: 'Profil başarıyla güncellendi',
        ));
        // Immediately transition to loaded state
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  /// Delete local profile cache
  Future<void> _onDeleteProfile(
    DeleteProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.deleteLocalProfile();

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const ProfileEmpty()),
    );
  }

  /// Refresh profile from backend (bypass cache)
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await repository.getProfile();

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }
}
