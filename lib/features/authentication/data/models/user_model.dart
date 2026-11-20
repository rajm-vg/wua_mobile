import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';

/// Data Transfer Object for User.
/// Handles JSON serialization/deserialization for wrd_backend Spring Boot API (LoginUserDTO)
/// as well as cached storage.
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
    this.firstName,
    this.lastName,
    this.societyId,
    this.username,
    this.refTable,
    this.refTableId,
    this.langKey,
    this.status,
    this.authorities = const [],
    this.roles = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final idStr = rawId != null ? rawId.toString() : '';

    final firstName = json['firstName'] as String?;
    final lastName = json['lastName'] as String?;
    String computedName = '';
    if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
      computedName = '$firstName $lastName';
    } else if (firstName != null && firstName.isNotEmpty) {
      computedName = firstName;
    } else if (lastName != null && lastName.isNotEmpty) {
      computedName = lastName;
    } else {
      computedName = json['name'] as String? ?? json['username'] as String? ?? '';
    }

    final phone = json['mobileNo'] as String? ??
        json['phone'] as String? ??
        json['username'] as String? ??
        '';

    final email = json['email'] as String? ?? '';
    final avatarUrl = json['imageUrl'] as String? ?? json['avatar_url'] as String?;

    // Status: 'A' in JHipster backend indicates Active
    final status = json['status'] as String? ?? '';
    final isVerified = status == 'A' || (json['is_verified'] as bool? ?? false);

    final createdAt = json['createdOn'] as String? ?? json['created_at'] as String? ?? '';

    final authorities = (json['authorities'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    final roles = (json['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    final societyId = json['societyId'] is int
        ? json['societyId'] as int
        : int.tryParse(json['societyId']?.toString() ?? '');

    final refTableId = json['refTableId'] is int
        ? json['refTableId'] as int
        : int.tryParse(json['refTableId']?.toString() ?? '');

    final roleStr = json['role'] as String? ??
        _deriveRoleString(roles, authorities, json['refTable'] as String?);

    return UserModel(
      id: idStr,
      name: computedName,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      role: roleStr,
      isVerified: isVerified,
      createdAt: createdAt,
      firstName: firstName,
      lastName: lastName,
      societyId: societyId,
      username: json['username'] as String?,
      refTable: json['refTable'] as String?,
      refTableId: refTableId,
      langKey: json['langKey'] as String?,
      status: status,
      authorities: authorities,
      roles: roles,
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
      firstName: entity.firstName,
      lastName: entity.lastName,
      societyId: entity.societyId,
      username: entity.username,
      refTable: entity.refTable,
      refTableId: entity.refTableId,
      authorities: entity.authorities,
      roles: entity.roles,
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
  final String? firstName;
  final String? lastName;
  final int? societyId;
  final String? username;
  final String? refTable;
  final int? refTableId;
  final String? langKey;
  final String? status;
  final List<String> authorities;
  final List<String> roles;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'mobileNo': phone,
      'avatar_url': avatarUrl,
      'role': role,
      'is_verified': isVerified,
      'created_at': createdAt,
      'createdOn': createdAt,
      'societyId': societyId,
      'username': username,
      'refTable': refTable,
      'refTableId': refTableId,
      'langKey': langKey,
      'status': status,
      'authorities': authorities,
      'roles': roles,
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
      firstName: firstName,
      lastName: lastName,
      societyId: societyId,
      username: username,
      refTable: refTable,
      refTableId: refTableId,
      authorities: authorities,
      roles: roles,
    );
  }

  static String _deriveRoleString(
    List<String> roles,
    List<String> authorities,
    String? refTable,
  ) {
    if (roles.any((r) =>
        r.contains('सचिव') ||
        r.toLowerCase().contains('sachiv') ||
        r.toLowerCase().contains('secretary'))) {
      return 'wua_official';
    }
    if (authorities.any((a) => a.contains('SUPER_ADMIN') || a.contains('ADMIN'))) {
      return 'admin';
    }
    if (authorities.any((a) => a.contains('SACHIV') || a.contains('SANCHALAK'))) {
      return 'wua_official';
    }
    if (refTable == 'SocietyFarmer') {
      return 'farmer';
    }
    return 'farmer';
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
