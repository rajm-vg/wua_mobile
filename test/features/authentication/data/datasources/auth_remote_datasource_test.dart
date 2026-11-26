import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/datasources/auth_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late AuthRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDataSourceImpl(
      apiClient: mockApiClient,
      enableDemoFallback: false,
    );
  });

  group('AuthRemoteDataSourceImpl (Live Integration - No Fallback)', () {
    const testUsername = '9922322710';
    const testPassword = 'admin';
    const testIdToken = 'eyJhbGciOiJIUzUxMiJ9.test-jwt-token';

    final tAccountData = <String, dynamic>{
      'id': 2100,
      'firstName': 'सुभाष रंगनाथ झिंजाड',
      'societyId': 1503,
      'username': '9922322710',
      'mobileNo': '9922322710',
      'email': '',
      'status': 'A',
      'authorities': ['SUPER_ADMIN_AND_SACHIV_AND_SANCHALAK_ONLY'],
      'roles': ['सचिव'],
    };

    test(
      'performs two-step login without fallback and returns user & tokens',
      () async {
        when(
          () => mockApiClient.post<Map<String, dynamic>>(
            ApiEndpoints.authenticate,
            data: {
              'username': testUsername,
              'password': testPassword,
              'rememberMe': false,
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.authenticate),
            statusCode: 200,
            data: {'id_token': testIdToken},
          ),
        );

        when(
          () => mockApiClient.get<Map<String, dynamic>>(
            ApiEndpoints.account,
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.account),
            statusCode: 200,
            data: tAccountData,
          ),
        );

        final result = await dataSource.login(
          identifier: testUsername,
          password: testPassword,
        );

        expect(result.tokens.accessToken, testIdToken);
        expect(result.user.username, testUsername);
        expect(result.user.name, 'सुभाष रंगनाथ झिंजाड');
        expect(result.user.role, 'wua_official');
        expect(result.user.societyId, 1503);

        verify(
          () => mockApiClient.post<Map<String, dynamic>>(
            ApiEndpoints.authenticate,
            data: {
              'username': testUsername,
              'password': testPassword,
              'rememberMe': false,
            },
          ),
        ).called(1);

        verify(
          () => mockApiClient.get<Map<String, dynamic>>(
            ApiEndpoints.account,
            options: any(named: 'options'),
          ),
        ).called(1);
      },
    );

    test(
      'rethrows UnauthorizedException when backend returns 401 (no fallback)',
      () async {
        when(
          () => mockApiClient.post<Map<String, dynamic>>(
            ApiEndpoints.authenticate,
            data: any<dynamic>(named: 'data'),
          ),
        ).thenThrow(
          const UnauthorizedException(message: 'Invalid credentials'),
        );

        expect(
          () => dataSource.login(
            identifier: testUsername,
            password: 'wrong_password',
          ),
          throwsA(isA<UnauthorizedException>()),
        );

        verifyNever(
          () => mockApiClient.get<Map<String, dynamic>>(
            ApiEndpoints.account,
            options: any<Options>(named: 'options'),
          ),
        );
      },
    );

    test('rethrows ServerException when server is unreachable or 500 (no fallback)', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiEndpoints.authenticate,
          data: any<dynamic>(named: 'data'),
        ),
      ).thenThrow(const ServerException(message: 'Connection refused'));

      expect(
        () =>
            dataSource.login(identifier: testUsername, password: testPassword),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException if empty id_token returned', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiEndpoints.authenticate,
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.authenticate),
          statusCode: 200,
          data: {'id_token': ''},
        ),
      );

      expect(
        () =>
            dataSource.login(identifier: testUsername, password: testPassword),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'sends POST /api/logout with authorization header and credentials',
      () async {
        when(
          () => mockApiClient.post<void>(
            ApiEndpoints.logout,
            data: any<dynamic>(named: 'data'),
            options: any<Options>(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ApiEndpoints.logout),
            statusCode: 200,
          ),
        );

        await dataSource.logout(testIdToken, username: testUsername);

        verify(
          () => mockApiClient.post<void>(
            ApiEndpoints.logout,
            data: {
              'username': testUsername,
              'password': '*****',
              'rememberMe': false,
            },
            options: any<Options>(named: 'options'),
          ),
        ).called(1);
      },
    );
  });

  group('AuthRemoteDataSourceImpl Error Handling (No Fallback)', () {
    const testUsername = '9922322710';

    test('rethrows ServerException when backend connection fails', () async {
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiEndpoints.authenticate,
          data: any<dynamic>(named: 'data'),
        ),
      ).thenThrow(const ServerException(message: 'Connection refused'));

      expect(
        () => dataSource.login(identifier: testUsername, password: 'admin'),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'rethrows UnauthorizedException when invalid credentials are provided',
      () async {
        when(
          () => mockApiClient.post<Map<String, dynamic>>(
            ApiEndpoints.authenticate,
            data: any<dynamic>(named: 'data'),
          ),
        ).thenThrow(
          const UnauthorizedException(message: 'Invalid credentials'),
        );

        expect(
          () => dataSource.login(
            identifier: '9876543210',
            password: 'WrongPassword',
          ),
          throwsA(isA<UnauthorizedException>()),
        );
      },
    );

    test('blocks ROLE_SUPER_ADMIN without societyId on login', () async {
      const token = 'eyJhbGciOiJIUzUxMiJ9.super-admin';
      when(
        () => mockApiClient.post<Map<String, dynamic>>(
          ApiEndpoints.authenticate,
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.authenticate),
          statusCode: 200,
          data: {'id_token': token},
        ),
      );
      when(
        () => mockApiClient.get<Map<String, dynamic>>(
          ApiEndpoints.account,
          options: any<Options>(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.account),
          statusCode: 200,
          data: {
            'id': 1,
            'username': '9999999999',
            'status': 'A',
            'societyId': null,
            'authorities': ['ROLE_SUPER_ADMIN'],
            'roles': ['ROLE_SUPER_ADMIN'],
          },
        ),
      );

      expect(
        () => dataSource.login(identifier: '9999999999', password: 'admin'),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
