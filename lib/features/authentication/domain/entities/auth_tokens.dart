import 'package:equatable/equatable.dart';

/// Token pair returned on successful authentication.
class AuthTokens extends Equatable {
  // seconds

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn];
}
