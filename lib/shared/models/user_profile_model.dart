class UserProfileModel {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool emailVerified;
  final String? authProvider;
  final String? profilePicture;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    required this.emailVerified,
    this.authProvider,
    this.profilePicture,
  });

  static T? _get<T>(Map<String, dynamic> json, String camelCase, String snakeCase) {
    return json[camelCase] as T? ?? json[snakeCase] as T?;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(_get<String>(json, 'createdAt', 'created_at')!),
      updatedAt: DateTime.parse(_get<String>(json, 'updatedAt', 'updated_at')!),
      emailVerified: _get<bool>(json, 'emailVerified', 'email_verified') ?? false,
      authProvider: _get<String>(json, 'authProvider', 'auth_provider'),
      profilePicture: _get<String>(json, 'profilePicture', 'profile_picture'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'emailVerified': emailVerified,
      'authProvider': authProvider,
      'profilePicture': profilePicture,
    };
  }
}
