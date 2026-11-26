import 'package:equatable/equatable.dart';

/// Core domain entity representing an authenticated farmer / WUA user.
/// Aligned with `security_user`, `society_farmer`, and `farm_details` database tables.
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
    this.firstName,
    this.lastName,
    this.societyId,
    this.username,
    this.refTable,
    this.refTableId,
    this.authorities = const [],
    this.roles = const [],
    this.surveyNo,
    this.village,
    this.farmArea,
    this.totalBalance,
    this.irrigationMethod,
    this.typeOfCrop,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final bool isVerified;
  final DateTime createdAt;
  final String? firstName;
  final String? lastName;
  final int? societyId;
  final String? username;
  final String? refTable;
  final int? refTableId;
  final List<String> authorities;
  final List<String> roles;

  // ─── Database Fields from `society_farmer` & `farm_details` ───
  final String? surveyNo;
  final String? village;
  final double? farmArea;
  final double? totalBalance;
  final String? irrigationMethod;
  final String? typeOfCrop;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    bool? isVerified,
    DateTime? createdAt,
    String? firstName,
    String? lastName,
    int? societyId,
    String? username,
    String? refTable,
    int? refTableId,
    List<String>? authorities,
    List<String>? roles,
    String? surveyNo,
    String? village,
    double? farmArea,
    double? totalBalance,
    String? irrigationMethod,
    String? typeOfCrop,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      societyId: societyId ?? this.societyId,
      username: username ?? this.username,
      refTable: refTable ?? this.refTable,
      refTableId: refTableId ?? this.refTableId,
      authorities: authorities ?? this.authorities,
      roles: roles ?? this.roles,
      surveyNo: surveyNo ?? this.surveyNo,
      village: village ?? this.village,
      farmArea: farmArea ?? this.farmArea,
      totalBalance: totalBalance ?? this.totalBalance,
      irrigationMethod: irrigationMethod ?? this.irrigationMethod,
      typeOfCrop: typeOfCrop ?? this.typeOfCrop,
    );
  }

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
    firstName,
    lastName,
    societyId,
    username,
    refTable,
    refTableId,
    authorities,
    roles,
    surveyNo,
    village,
    farmArea,
    totalBalance,
    irrigationMethod,
    typeOfCrop,
  ];
}

/// User roles within the WUA system.
enum UserRole { farmer, wuaOfficial, governmentDepartment, admin }
