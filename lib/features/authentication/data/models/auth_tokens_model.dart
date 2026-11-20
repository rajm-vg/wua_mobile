import 'package:wua_mobile/features/authentication/domain/entities/auth_tokens.dart';

/// Data Transfer Object for authentication tokens.
class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final token = (json['id_token'] ??
            json['access_token'] ??
            json['token'] ??
            json['accessToken']) as String? ??
        '';
    return AuthTokensModel(
      accessToken: token,
      refreshToken: (json['refresh_token'] ?? json['refreshToken']) as String? ?? '',
      expiresIn: (json['expires_in'] ?? json['expiresIn']) as int? ?? 86400,
    );
  }
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }

  /// Maps this DTO to a domain entity.
  AuthTokens toEntity() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
  }
}
