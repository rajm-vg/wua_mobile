import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_cached_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication Bloc.
///
/// Depends only on use cases — never touches repositories or data sources.
/// Each event handler delegates to a single use case.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUseCase,
    required this._registerUseCase,
    required this._logoutUseCase,
    required this._getCachedUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCachedUserUseCase _getCachedUserUseCase;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(identifier: event.identifier, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (data) => emit(AuthAuthenticated(user: data.user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (data) => emit(AuthAuthenticated(user: data.user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _logoutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCachedUserUseCase(const NoParams());

    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
}
