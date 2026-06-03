class UserModel {
  final String userId;
  final String username;
  final String name;
  final String token;

  UserModel({
    required this.userId,
    required this.username,
    required this.name,
    required this.token,
  });

  // Manual dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }

  // Manual ke JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'name': name,
      'token': token,
    };
  }
}
