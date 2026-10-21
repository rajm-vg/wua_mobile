import 'package:equatable/equatable.dart';

/// Core domain entity representing an authenticated user.
/// This is the business object — no serialization logic here.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    avatarUrl,
    role,
    isVerified,
    createdAt,
  ];
}

/// User roles within the WUA system.
enum UserRole { farmer, wuaOfficial, governmentDepartment, admin }
