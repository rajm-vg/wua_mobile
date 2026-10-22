import 'dart:convert';

import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';
import 'package:wua_mobile/features/authentication/data/models/user_model.dart';

/// Contract for local authentication data operations.
abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearCache();
  Future<bool> hasToken();
}

/// Concrete implementation using [SecureStorageService].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required this.secureStorage});
  final SecureStorageService secureStorage;

  @override
  Future<void> cacheUser(UserModel user) async {
    await secureStorage.saveUserData(jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel> getCachedUser() async {
    final jsonString = await secureStorage.getUserData();
    if (jsonString == null || jsonString.isEmpty) {
      throw const CacheException(message: 'No cached user found.');
    }
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      secureStorage.saveAccessToken(accessToken),
      secureStorage.saveRefreshToken(refreshToken),
    ]);
  }

  @override
  Future<void> clearCache() async {
    await Future.wait([
      secureStorage.clearTokens(),
      secureStorage.deleteUserData(),
    ]);
  }

  @override
  Future<bool> hasToken() => secureStorage.hasToken();
}
