import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/authentication/domain/entities/auth_tokens.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:wua_mobile/features/authentication/domain/usecases/login_usecase.dart';

// ─── Mocks ────────────────────────────────────────────────────
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

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

  const tParams = LoginParams(
    identifier: 'farmer@example.com',
    password: 'Password123',
  );

  test('should return user and tokens on successful login', () async {
    // Arrange
    when(() => mockRepository.login(
          identifier: any(named: 'identifier'),
          password: any(named: 'password'),
        )).thenAnswer(
      (_) async => Right((user: tUser, tokens: tTokens)),
    );

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, Right<Failure, ({UserEntity user, AuthTokens tokens})>(
      (user: tUser, tokens: tTokens),
    ));
    verify(() => mockRepository.login(
          identifier: tParams.identifier,
          password: tParams.password,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure on failed login', () async {
    // Arrange
    when(() => mockRepository.login(
          identifier: any(named: 'identifier'),
          password: any(named: 'password'),
        )).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'Invalid credentials')),
    );

    // Act
    final result = await useCase(tParams);

    // Assert
    expect(result, const Left<Failure, ({UserEntity user, AuthTokens tokens})>(
      ServerFailure(message: 'Invalid credentials'),
    ));
  });
}
