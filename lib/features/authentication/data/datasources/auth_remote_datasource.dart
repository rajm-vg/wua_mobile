import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

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

/// Concrete implementation calling the REST API via [ApiClient].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<({UserModel user, AuthTokensModel tokens})> login({
    required String identifier,
    required String password,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'identifier': identifier, 'password': password},
    );

    final data = response.data!;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      tokens: AuthTokensModel.fromJson(data),
    );
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
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data!;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      tokens: AuthTokensModel.fromJson(data),
    );
  }

  @override
  Future<void> logout(String accessToken) async {
    await apiClient.post<void>(ApiEndpoints.logout);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await apiClient.post<void>(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await apiClient.post<void>(
      ApiEndpoints.resetPassword,
      data: {'email': email, 'otp': otp, 'new_password': newPassword},
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await apiClient.post<void>(
      ApiEndpoints.verifyOtp,
      data: {'email': email, 'otp': otp},
    );
  }
}
