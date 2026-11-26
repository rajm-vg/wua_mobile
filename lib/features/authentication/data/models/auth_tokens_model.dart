import 'package:wua_mobile/core/utils/json_parse_utils.dart';
import 'package:wua_mobile/features/authentication/domain/entities/auth_tokens.dart';

/// Data Transfer Object for authentication tokens.
class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final token = JsonParseUtils.parseString(
      json['id_token'] ??
          json['access_token'] ??
          json['token'] ??
          json['accessToken'],
    );
    return AuthTokensModel(
      accessToken: token,
      refreshToken: JsonParseUtils.parseString(
        json['refresh_token'] ?? json['refreshToken'],
      ),
      expiresIn: JsonParseUtils.parseInt(
        json['expires_in'] ?? json['expiresIn'],
        defaultValue: 86400,
      ),
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
