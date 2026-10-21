import 'package:equatable/equatable.dart';

/// Events consumed by [AuthBloc].
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// User submitted login credentials.
class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.identifier, required this.password});
  final String identifier;
  final String password;

  @override
  List<Object?> get props => [identifier, password];
}

/// User submitted registration form.
class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
  final String name;
  final String email;
  final String phone;
  final String password;

  @override
  List<Object?> get props => [name, email, phone, password];
}

/// User requested logout.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Check if user is already authenticated (app startup).
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
