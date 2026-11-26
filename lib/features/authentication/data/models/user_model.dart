import 'package:wua_mobile/core/utils/json_parse_utils.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';

/// Data Transfer Object for User aligned with `security_user`, `society_farmer`, and `farm_details`.
/// Handles JSON serialization/deserialization for wrd_backend Spring Boot API (LoginUserDTO, SocietyFarmerDTO)
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
    this.surveyNo,
    this.village,
    this.farmArea,
    this.totalBalance,
    this.irrigationMethod,
    this.typeOfCrop,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final idStr = JsonParseUtils.parseString(json['id']);

    final firstName = JsonParseUtils.parseStringOrNull(json['firstName']);
    final lastName = JsonParseUtils.parseStringOrNull(json['lastName']);
    String computedName = '';
    if (firstName != null && lastName != null) {
      computedName = '$firstName $lastName';
    } else if (firstName != null) {
      computedName = firstName;
    } else if (lastName != null) {
      computedName = lastName;
    } else {
      computedName = JsonParseUtils.parseString(
        json['name'] ?? json['sName'] ?? json['username'],
      );
    }

    final phone = JsonParseUtils.parseString(
      json['mobileNo'] ?? json['phone'] ?? json['username'],
    );

    final email = JsonParseUtils.parseString(json['email']);
    final rawAvatar = JsonParseUtils.parseStringOrNull(
      json['imageUrl'] ?? json['avatar_url'],
    );
    final avatarUrl = _normalizeAvatar(rawAvatar);

    // Status: 'A' in JHipster backend indicates Active
    final status = JsonParseUtils.parseString(json['status']);
    final isVerified =
        status == 'A' || JsonParseUtils.parseBool(json['is_verified']);

    final createdAt = JsonParseUtils.parseString(
      json['createdOn'] ?? json['created_at'],
    );

    final authorities = JsonParseUtils.parseStringList(json['authorities']);
    final roles = JsonParseUtils.parseStringList(json['roles']);

    final societyId = JsonParseUtils.parseIntOrNull(
      json['societyId'] ?? json['iSocietyId'],
    );
    final refTableId = JsonParseUtils.parseIntOrNull(json['refTableId']);
    final refTable = JsonParseUtils.parseStringOrNull(json['refTable']);

    final roleStr = JsonParseUtils.parseStringOrNull(json['role']) ??
        _deriveRoleString(roles, authorities, refTable);

    final farmArea = JsonParseUtils.parseDoubleOrNull(
      json['nFarmArea'] ?? json['farmArea'] ?? json['farm_area'] ?? json['area'],
    );
    final totalBalance = JsonParseUtils.parseDoubleOrNull(
      json['nTotalBalance'] ?? json['totalBalance'] ?? json['total_balance'],
    );

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
      username: JsonParseUtils.parseStringOrNull(json['username']),
      refTable: refTable,
      refTableId: refTableId,
      langKey: JsonParseUtils.parseStringOrNull(json['langKey']),
      status: status,
      authorities: authorities,
      roles: roles,
      surveyNo: JsonParseUtils.parseStringOrNull(
        json['sSurveyNo'] ?? json['surveyNo'] ?? json['survey_no'],
      ),
      village: JsonParseUtils.parseStringOrNull(
        json['sVillage'] ?? json['village'],
      ),
      farmArea: farmArea,
      totalBalance: totalBalance,
      irrigationMethod: JsonParseUtils.parseStringOrNull(
        json['sIrrigationMethod'] ?? json['irrigationMethod'],
      ),
      typeOfCrop: JsonParseUtils.parseStringOrNull(
        json['sTypeOfCrop'] ?? json['typeOfCrop'],
      ),
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
      surveyNo: entity.surveyNo,
      village: entity.village,
      farmArea: entity.farmArea,
      totalBalance: entity.totalBalance,
      irrigationMethod: entity.irrigationMethod,
      typeOfCrop: entity.typeOfCrop,
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

  // ─── Society Farmer & Farm Details ─────────────────────────
  final String? surveyNo;
  final String? village;
  final double? farmArea;
  final double? totalBalance;
  final String? irrigationMethod;
  final String? typeOfCrop;

  bool get isFarmerMember =>
      refTable == 'SocietyFarmer' ||
      (refTable == null &&
          (roles.any(
                (r) =>
                    r.contains('सभासद') ||
                    r.toUpperCase() == 'ROLE_FARMER',
              ) ||
              role == 'farmer'));

  int? get effectiveFarmerMemberId =>
      isFarmerMember ? (refTableId ?? int.tryParse(id)) : null;

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
      'iSocietyId': societyId,
      'username': username,
      'refTable': refTable,
      'refTableId': refTableId,
      'langKey': langKey,
      'status': status,
      'authorities': authorities,
      'roles': roles,
      'sSurveyNo': surveyNo,
      'surveyNo': surveyNo,
      'sVillage': village,
      'village': village,
      'nFarmArea': farmArea,
      'farmArea': farmArea,
      'nTotalBalance': totalBalance,
      'totalBalance': totalBalance,
      'sIrrigationMethod': irrigationMethod,
      'irrigationMethod': irrigationMethod,
      'sTypeOfCrop': typeOfCrop,
      'typeOfCrop': typeOfCrop,
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
      surveyNo: surveyNo,
      village: village,
      farmArea: farmArea,
      totalBalance: totalBalance,
      irrigationMethod: irrigationMethod,
      typeOfCrop: typeOfCrop,
    );
  }

  static String? _normalizeAvatar(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('data:')) {
      return trimmed;
    }
    // LoginUserDTO.imageUrl is a byte[] serialized as raw Base64.
    return 'data:image/jpeg;base64,$trimmed';
  }

  static String _deriveRoleString(
    List<String> roles,
    List<String> authorities,
    String? refTable,
  ) {
    if (roles.any((r) =>
        r.contains('सभासद') ||
        r.toLowerCase().contains('sabhasad') ||
        r.contains('शेतकरी') ||
        r.toLowerCase().contains('farmer'))) {
      return 'farmer';
    }
    if (roles.any((r) =>
        r.contains('सचिव') ||
        r.contains('संचालक') ||
        r.toLowerCase().contains('sachiv') ||
        r.toLowerCase().contains('sanchalak') ||
        r.toLowerCase().contains('secretary'))) {
      return 'wua_official';
    }
    if (authorities.any((a) => a.contains('SUPER_ADMIN') || a.contains('ADMIN'))) {
      return 'admin';
    }
    if (authorities.any((a) => a.contains('SACHIV') || a.contains('SANCHALAK'))) {
      return 'wua_official';
    }
    if (roles.any((r) => r.contains('सभासद') || r.toUpperCase() == 'ROLE_FARMER')) {
      return 'farmer';
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
