import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';

/// Data Transfer Object for User.
/// Handles JSON serialization/deserialization.
/// Mapped to [UserEntity] before crossing into the domain layer.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'farmer',
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  /// Creates a model from a domain entity (for caching).
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      role: entity.role.name,
      isVerified: entity.isVerified,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String role;
  final bool isVerified;
  final String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt,
    };
  }

  /// Maps this DTO to a domain entity.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      role: _mapRole(role),
      isVerified: isVerified,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  static UserRole _mapRole(String role) {
    switch (role) {
      case 'farmer':
        return UserRole.farmer;
      case 'wua_official':
        return UserRole.wuaOfficial;
      case 'government_department':
        return UserRole.governmentDepartment;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.farmer;
    }
  }
}
