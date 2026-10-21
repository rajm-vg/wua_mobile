import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/authentication/domain/entities/auth_tokens.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/features/authentication/domain/usecases/get_cached_user_usecase.dart';
import 'package:wua_mobile/features/authentication/domain/usecases/login_usecase.dart';
import 'package:wua_mobile/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:wua_mobile/features/authentication/domain/usecases/register_usecase.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_state.dart';

// ─── Mocks ────────────────────────────────────────────────────
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCachedUserUseCase extends Mock implements GetCachedUserUseCase {}

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCachedUserUseCase mockGetCachedUserUseCase;

  final tUser = UserEntity(
    id: '123',
    name: 'Test Farmer',
    email: 'farmer@example.com',
    phone: '9876543210',
    role: UserRole.farmer,
    isVerified: true,
    createdAt: DateTime(2024),
  );

  const tTokens = AuthTokens(
    accessToken: 'access_123',
    refreshToken: 'refresh_123',
    expiresIn: 3600,
  );

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCachedUserUseCase = MockGetCachedUserUseCase();

    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCachedUserUseCase: mockGetCachedUserUseCase,
    );
  });

  setUpAll(() {
    registerFallbackValue(const LoginParams(
      identifier: '',
      password: '',
    ));
    registerFallbackValue(const NoParams());
  });

  tearDown(() => bloc.close());

  test('initial state should be AuthInitial', () {
    expect(bloc.state, const AuthInitial());
  });

  group('AuthLoginRequested', () {
    const tEvent = AuthLoginRequested(
      identifier: 'farmer@example.com',
      password: 'Password123',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(() => mockLoginUseCase(any()))
            .thenAnswer((_) async => Right((user: tUser, tokens: tTokens)));
        return bloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] on failure',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Invalid credentials'),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Invalid credentials'),
      ],
    );
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when cached user exists',
      build: () {
        when(() => mockGetCachedUserUseCase(any()))
            .thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(user: tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no cached user',
      build: () {
        when(() => mockGetCachedUserUseCase(any())).thenAnswer(
          (_) async => const Left(CacheFailure()),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on success',
      build: () {
        when(() => mockLogoutUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
