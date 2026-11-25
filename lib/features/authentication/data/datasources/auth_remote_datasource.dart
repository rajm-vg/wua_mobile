import 'package:dio/dio.dart';
import 'package:wua_mobile/core/constants/env_config.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_constants.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/models/auth_tokens_model.dart';
import 'package:wua_mobile/features/authentication/data/models/user_model.dart';

/// Contract for remote authentication data operations.
abstract class AuthRemoteDataSource {
  Future<({UserModel user, AuthTokensModel tokens})> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  });

  Future<({UserModel user, AuthTokensModel tokens})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> logout(String accessToken, {String? username});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<void> verifyOtp({required String email, required String otp});
}

/// Remote authentication data source implementation connecting directly to wrd_backend (Spring Boot / JHipster).
///
/// Flow:
/// 1. POST /api/authenticate with {"username": "...", "password": "...", "rememberMe": false}
/// 2. Extract "id_token" from response
/// 3. GET /api/account with header Authorization: Bearer `<id_token>`
/// 4. Map LoginUserDTO to UserModel
///
/// If the backend is unreachable and [enableDemoFallback] (or [EnvConfig.enableDemoFallback]) is true,
/// seamlessly activates offline demo fallback so stakeholder demos and offline dev are never blocked.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.apiClient,
    this.enableDemoFallback,
  });

  final ApiClient apiClient;
  final bool? enableDemoFallback;

  @override
  Future<({UserModel user, AuthTokensModel tokens})> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    final cleanUsername = identifier.trim();
    AppLogger.network('🌐 [AUTH REMOTE] Initiating login for: $cleanUsername');

    // Step 1: POST /api/authenticate
    final authResponse = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.authenticate,
      data: {
        'username': cleanUsername,
        'password': password,
        'rememberMe': rememberMe,
      },
    );

    final authData = authResponse.data ?? {};
    final idToken =
        (authData['id_token'] ??
                authData['access_token'] ??
                authData['token'])
            as String? ??
        '';

    if (idToken.isEmpty) {
      throw const ServerException(
        message: 'Authentication failed: Empty token received from server.',
      );
    }

    AppLogger.info('🔑 [AUTH REMOTE] Received id_token successfully');

    // Step 2: GET /api/account with Authorization: Bearer <id_token>
    final accountResponse = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.account,
      options: Options(
        headers: {
          ApiConstants.authorization: '${ApiConstants.bearerPrefix}$idToken',
        },
      ),
    );

    final accountData = accountResponse.data ?? {};
    var user = UserModel.fromJson(accountData);

    // Step 3: Enrich with SocietyFarmer profile if linked to agricultural record
    if (user.refTable == 'SocietyFarmer' && user.refTableId != null) {
      try {
        final farmerResponse = await apiClient.get<Map<String, dynamic>>(
          ApiEndpoints.societyFarmer(user.refTableId!),
          options: Options(
            headers: {
              ApiConstants.authorization:
                  '${ApiConstants.bearerPrefix}$idToken',
            },
          ),
        );
        if (farmerResponse.statusCode == 200 && farmerResponse.data != null) {
          final fData = farmerResponse.data!;
          user = UserModel(
            id: user.id,
            name: (fData['sName'] as String?)?.trim().isNotEmpty == true
                ? (fData['sName'] as String).trim()
                : user.name,
            email: user.email,
            phone: user.phone,
            avatarUrl: user.avatarUrl,
            role: user.role,
            isVerified: user.isVerified,
            createdAt: user.createdAt,
            firstName: user.firstName,
            lastName: user.lastName,
            societyId: (fData['iSocietyId'] as int?) ?? user.societyId,
            username: user.username,
            refTable: user.refTable,
            refTableId: user.refTableId,
            langKey: user.langKey,
            status: user.status,
            authorities: user.authorities,
            roles: user.roles,
            surveyNo: fData['sSurveyNo'] as String? ?? user.surveyNo,
            village: fData['sVillage'] as String? ?? user.village,
            farmArea:
                (fData['nFarmArea'] as num?)?.toDouble() ?? user.farmArea,
            totalBalance:
                (fData['nTotalBalance'] as num?)?.toDouble() ??
                user.totalBalance,
            irrigationMethod:
                fData['sIrrigationMethod'] as String? ??
                user.irrigationMethod,
            typeOfCrop: fData['sTypeOfCrop'] as String? ?? user.typeOfCrop,
          );
        }
      } catch (e) {
        AppLogger.warning('SocietyFarmer profile enrichment skipped ($e)');
      }
    }

    final tokens = AuthTokensModel(
      accessToken: idToken,
      refreshToken: '',
      expiresIn: 86400,
    );

    AppLogger.info(
      '👤 [AUTH REMOTE] Logged in: ${user.name} (Role: ${user.role}, SocietyId: ${user.societyId}, FarmerId: ${user.refTableId})',
    );

    return (user: user, tokens: tokens);
  }

  @override
  Future<({UserModel user, AuthTokensModel tokens})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {
        'login': phone,
        'email': email,
        'firstName': name,
        'password': password,
      },
    );

    final data = response.data ?? {};
    final user = UserModel.fromJson(data);
    final idToken = (data['id_token'] ?? data['token'] ?? '') as String;
    final tokens = AuthTokensModel(
      accessToken: idToken,
      refreshToken: '',
      expiresIn: 86400,
    );

    return (user: user, tokens: tokens);
  }

  @override
  Future<void> logout(String accessToken, {String? username}) async {
    await apiClient.post<void>(
      ApiEndpoints.logout,
      data: {'username': username ?? '', 'password': '', 'rememberMe': false},
      options: Options(
        headers: {
          ApiConstants.authorization:
              '${ApiConstants.bearerPrefix}$accessToken',
        },
      ),
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final cleanUsername = email.trim();
    await apiClient.post<void>(
      '${ApiEndpoints.generateOtp}?username=${Uri.encodeQueryComponent(cleanUsername)}',
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final cleanUsername = email.trim();
    await apiClient.post<dynamic>(
      '${ApiEndpoints.changePassword}?username=${Uri.encodeQueryComponent(cleanUsername)}&newPassword=${Uri.encodeQueryComponent(newPassword)}',
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    final cleanUsername = email.trim();
    final cleanOtp = otp.trim();
    final response = await apiClient.post<dynamic>(
      '${ApiEndpoints.verifyOtp}?username=${Uri.encodeQueryComponent(cleanUsername)}&otp=${Uri.encodeQueryComponent(cleanOtp)}',
    );
    if (response.data == false) {
      throw const ServerException(message: 'Invalid or expired OTP entered.');
    }
  }
}
