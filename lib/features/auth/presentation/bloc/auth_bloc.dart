import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.register(
      email: event.email,
      password: event.password,
      name: event.name,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('[AUTH BLOC] LoginRequested event alındı!');
    print('[AUTH BLOC] Email: ${event.email}');

    emit(const AuthLoading());
    print('[AUTH BLOC] AuthLoading state emit edildi');

    final result = await authRepository.login(
      email: event.email,
      password: event.password,
    );

    print('[AUTH BLOC] Repository sonucu alındı');

    result.fold(
      (failure) {
        print('[AUTH BLOC] Login BAŞARISIZ: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        print('[AUTH BLOC] Login BAŞARILI: ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );

    print('[AUTH BLOC] Son state emit edildi');
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final isLoggedIn = await authRepository.isLoggedIn();

    if (isLoggedIn) {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(const AuthUnauthenticated()),
        (user) => emit(AuthAuthenticated(user)),
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
