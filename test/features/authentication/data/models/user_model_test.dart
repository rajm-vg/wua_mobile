import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/features/authentication/data/models/user_model.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';

/// Unit tests for [UserModel] — serialization and entity mapping.
void main() {
  const tUserModel = UserModel(
    id: '123',
    name: 'Test Farmer',
    email: 'farmer@example.com',
    phone: '9876543210',
    avatarUrl: null,
    role: 'farmer',
    isVerified: true,
    createdAt: '2024-01-01T00:00:00.000Z',
  );

  final tUserJson = {
    'id': '123',
    'name': 'Test Farmer',
    'email': 'farmer@example.com',
    'phone': '9876543210',
    'avatar_url': null,
    'role': 'farmer',
    'is_verified': true,
    'created_at': '2024-01-01T00:00:00.000Z',
  };

  group('UserModel', () {
    test('fromJson should return a valid model', () {
      final result = UserModel.fromJson(tUserJson);
      expect(result.id, tUserModel.id);
      expect(result.name, tUserModel.name);
      expect(result.email, tUserModel.email);
      expect(result.role, tUserModel.role);
    });

    test('toJson should return a valid map', () {
      final result = tUserModel.toJson();
      expect(result['id'], '123');
      expect(result['email'], 'farmer@example.com');
      expect(result['role'], 'farmer');
    });

    test('toEntity should map correctly to UserEntity', () {
      final entity = tUserModel.toEntity();
      expect(entity, isA<UserEntity>());
      expect(entity.id, tUserModel.id);
      expect(entity.name, tUserModel.name);
      expect(entity.role, UserRole.farmer);
    });

    test('fromEntity should create model from entity', () {
      final entity = tUserModel.toEntity();
      final model = UserModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.email, entity.email);
    });
  });
}
