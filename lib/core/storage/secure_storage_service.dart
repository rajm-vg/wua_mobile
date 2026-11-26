import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wua_mobile/core/constants/app_constants.dart';

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

  static const String _pendingPaymentKey = 'pending_easebuzz_payment';

  // ─── Pending Payment Recovery ───────────────────────────────

  Future<void> savePendingPayment(String jsonString) async {
    await _storage.write(key: _pendingPaymentKey, value: jsonString);
  }

  Future<String?> getPendingPayment() async {
    return _storage.read(key: _pendingPaymentKey);
  }

  Future<void> clearPendingPayment() async {
    await _storage.delete(key: _pendingPaymentKey);
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

  /// Returns true if a non-empty, non-expired access token exists.
  /// If the stored token is a JWT whose `exp` claim is in the past,
  /// clears tokens and returns false.
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;
    if (isJwtExpired(token)) {
      await clearTokens();
      return false;
    }
    return true;
  }

  /// Checks whether a JWT token's `exp` claim is in the past.
  /// Returns false for non-JWT / opaque tokens or tokens without an `exp` claim.
  static bool isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(payloadJson);
      if (payload is Map<String, dynamic> && payload['exp'] is num) {
        final expSeconds = (payload['exp'] as num).toInt();
        final expiry = DateTime.fromMillisecondsSinceEpoch(
          expSeconds * 1000,
          isUtc: true,
        );
        return DateTime.now().toUtc().isAfter(expiry);
      }
    } catch (_) {
      // Ignore malformed payloads for non-standard tokens.
    }
    return false;
  }
}
