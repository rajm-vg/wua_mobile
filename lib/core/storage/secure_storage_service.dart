import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Abstraction over [FlutterSecureStorage] for sensitive data.
/// Stores access tokens, refresh tokens, and user credentials.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );
  final FlutterSecureStorage _storage;

  // ─── Access Token ───────────────────────────────────────────

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
  }

  // ─── Refresh Token ──────────────────────────────────────────

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // ─── User Data ──────────────────────────────────────────────

  Future<void> saveUserData(String jsonString) async {
    await _storage.write(key: AppConstants.userDataKey, value: jsonString);
  }

  Future<String?> getUserData() async {
    return _storage.read(key: AppConstants.userDataKey);
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.userDataKey);
  }

  // ─── Generic Secure Read/Write ──────────────────────────────

  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  Future<void> deleteKey({required String key}) async {
    await _storage.delete(key: key);
  }

  // ─── Bulk Operations ───────────────────────────────────────

  /// Clears both access and refresh tokens.
  Future<void> clearTokens() async {
    await Future.wait([deleteAccessToken(), deleteRefreshToken()]);
  }

  /// Wipes all data from secure storage.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Returns true if an access token exists.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
