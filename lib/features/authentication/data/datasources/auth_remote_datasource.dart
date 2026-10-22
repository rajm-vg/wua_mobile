import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/models/auth_tokens_model.dart';
import 'package:wua_mobile/features/authentication/data/models/user_model.dart';

/// Contract for remote authentication data operations.
abstract class AuthRemoteDataSource {
  Future<({UserModel user, AuthTokensModel tokens})> login({
    required String identifier,
    required String password,
  });

  Future<({UserModel user, AuthTokensModel tokens})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> logout(String accessToken);

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<void> verifyOtp({required String email, required String otp});
}

/// Remote authentication data source implementation.
/// Currently returns simulated mock data for development and testing.
/// In the future, the commented [apiClient] calls will be activated.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<({UserModel user, AuthTokensModel tokens})> login({
    required String identifier,
    required String password,
  }) async {
    // Simulated network delay (600ms) for realistic UX and loading states
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // TODO: When backend API is ready, uncomment the real API call:
    // final response = await apiClient.post<Map<String, dynamic>>(
    //   ApiEndpoints.login,
    //   data: {'identifier': identifier, 'password': password},
    // );
    // final data = response.data!;
    // return (
    //   user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    //   tokens: AuthTokensModel.fromJson(data),
    // );

    AppLogger.info(
      '🔑 [MOCK AUTH] Login simulated for "$identifier" (Endpoint: ${ApiEndpoints.login})',
    );

    final cleanId = identifier.trim().toLowerCase();
    final UserModel user;

    // Match demo accounts / quick role chips
    if (cleanId == '9876543210' || cleanId.contains('farmer')) {
      user = const UserModel(
        id: 'usr_farmer_001',
        name: 'Ramesh Patel',
        email: 'farmer@wua.gov.in',
        phone: '9876543210',
        role: 'farmer',
        isVerified: true,
        createdAt: '2023-01-15T08:30:00.000Z',
      );
    } else if (cleanId == 'official@wua.gov.in' ||
        cleanId.contains('official')) {
      user = const UserModel(
        id: 'usr_official_002',
        name: 'Sunita Sharma (Executive Engineer)',
        email: 'official@wua.gov.in',
        phone: '9876543211',
        role: 'wua_official',
        isVerified: true,
        createdAt: '2022-06-10T10:15:00.000Z',
      );
    } else if (cleanId == 'admin@wrd.gov.in' || cleanId.contains('admin')) {
      user = const UserModel(
        id: 'usr_admin_003',
        name: 'Rajesh Varma (WRD Administrator)',
        email: 'admin@wrd.gov.in',
        phone: '9876543212',
        role: 'admin',
        isVerified: true,
        createdAt: '2021-03-22T11:45:00.000Z',
      );
    } else if (cleanId == 'officer@wrd.gov.in' ||
        cleanId.contains('officer') ||
        cleanId.contains('dept')) {
      user = const UserModel(
        id: 'usr_dept_004',
        name: 'Dr. Vikramaditya Singh (Superintending Engineer)',
        email: 'officer@wrd.gov.in',
        phone: '9876543213',
        role: 'government_department',
        isVerified: true,
        createdAt: '2020-01-01T00:00:00.000Z',
      );
    } else {
      // Dynamic fallback for any valid phone number or email
      final isEmail = identifier.contains('@');
      user = UserModel(
        id: 'usr_sim_${DateTime.now().millisecondsSinceEpoch}',
        name: isEmail
            ? identifier.split('@').first.replaceAll('.', ' ').toUpperCase()
            : 'Farmer ($identifier)',
        email: isEmail ? identifier : '$identifier@wua.gov.in',
        phone: isEmail ? '9876543210' : identifier,
        role: 'farmer',
        isVerified: true,
        createdAt: DateTime.now().toIso8601String(),
      );
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tokens = AuthTokensModel(
      accessToken: 'mock_jwt_access_${user.role}_$timestamp',
      refreshToken: 'mock_jwt_refresh_${user.role}_$timestamp',
      expiresIn: 3600,
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
    // Simulated network delay (600ms)
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // TODO: When backend API is ready, uncomment the real API call:
    // final response = await apiClient.post<Map<String, dynamic>>(
    //   ApiEndpoints.register,
    //   data: {
    //     'name': name,
    //     'email': email,
    //     'phone': phone,
    //     'password': password,
    //   },
    // );
    // final data = response.data!;
    // return (
    //   user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    //   tokens: AuthTokensModel.fromJson(data),
    // );

    AppLogger.info(
      '🔑 [MOCK AUTH] Registration simulated for: $email (Endpoint: ${ApiEndpoints.register})',
    );

    final user = UserModel(
      id: 'usr_reg_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: 'farmer',
      isVerified: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tokens = AuthTokensModel(
      accessToken: 'mock_jwt_access_farmer_$timestamp',
      refreshToken: 'mock_jwt_refresh_farmer_$timestamp',
      expiresIn: 3600,
    );

    return (user: user, tokens: tokens);
  }

  @override
  Future<void> logout(String accessToken) async {
    // Simulated network delay (300ms)
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // TODO: When backend API is ready, uncomment the real API call:
    // await apiClient.post<void>(ApiEndpoints.logout);

    AppLogger.info(
      '🔑 [MOCK AUTH] Logout simulated (Endpoint: ${ApiEndpoints.logout})',
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    // Simulated network delay (500ms)
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // TODO: When backend API is ready, uncomment the real API call:
    // await apiClient.post<void>(
    //   ApiEndpoints.forgotPassword,
    //   data: {'email': email},
    // );

    AppLogger.info(
      '🔑 [MOCK AUTH] OTP 123456 sent to $email (Endpoint: ${ApiEndpoints.forgotPassword})',
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    // Simulated network delay (500ms)
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // TODO: When backend API is ready, uncomment the real API call:
    // await apiClient.post<void>(
    //   ApiEndpoints.resetPassword,
    //   data: {'email': email, 'otp': otp, 'new_password': newPassword},
    // );

    AppLogger.info(
      '🔑 [MOCK AUTH] Password reset simulated for $email (Endpoint: ${ApiEndpoints.resetPassword})',
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    // Simulated network delay (500ms)
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // TODO: When backend API is ready, uncomment the real API call:
    // await apiClient.post<void>(
    //   ApiEndpoints.verifyOtp,
    //   data: {'email': email, 'otp': otp},
    // );

    AppLogger.info(
      '🔑 [MOCK AUTH] OTP verified for $email (Endpoint: ${ApiEndpoints.verifyOtp})',
    );
  }
}
