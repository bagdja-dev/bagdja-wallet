class OrganizationModel {
  final String id;
  final String name;
  final String orgId;
  final String? description;
  final bool isActive;
  final String? logo;
  final String? contactEmail;
  final bool isSystemOrg;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? role;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.orgId,
    this.description,
    required this.isActive,
    this.logo,
    this.contactEmail,
    required this.isSystemOrg,
    required this.createdAt,
    required this.updatedAt,
    this.role,
  });

  static T? _get<T>(Map<String, dynamic> json, String camelCase, String snakeCase) {
    return json[camelCase] as T? ?? json[snakeCase] as T?;
  }

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      orgId: _get<String>(json, 'orgId', 'org_id')!,
      description: json['description'] as String?,
      isActive: _get<bool>(json, 'isActive', 'is_active') ?? false,
      logo: json['logo'] as String?,
      contactEmail: _get<String>(json, 'contactEmail', 'contact_email'),
      isSystemOrg: _get<bool>(json, 'isSystemOrg', 'is_system_org') ?? false,
      createdAt: DateTime.parse(_get<String>(json, 'createdAt', 'created_at')!),
      updatedAt: DateTime.parse(_get<String>(json, 'updatedAt', 'updated_at')!),
      role: json['role'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'orgId': orgId,
      'description': description,
      'isActive': isActive,
      'logo': logo,
      'contactEmail': contactEmail,
      'isSystemOrg': isSystemOrg,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'role': role,
    };
  }
}

class WalletOwner {
  final String id;
  final String name;
  final String? orgId;
  final bool isPersonal;
  final String? logo;
  final String? description;

  WalletOwner({
    required this.id,
    required this.name,
    this.orgId,
    required this.isPersonal,
    this.logo,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WalletOwner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
