import 'package:jwt_decode/jwt_decode.dart';

class UserModel {
  final String userId;
  final String? email;
  final String? username;
  final String? name;
  final String token;

  UserModel({
    required this.userId,
    this.email,
    this.username,
    this.name,
    required this.token,
  });

  // Buat UserModel dari token JWT
  factory UserModel.fromToken(String token) {
    final Map<String, dynamic> payload = Jwt.parseJwt(token);
    return UserModel(
      userId: payload['sub']?.toString() ?? '',
      email: payload['email']?.toString(),
      username: payload['preferred_username']?.toString() ?? payload['username']?.toString(),
      name: payload['name']?.toString(),
      token: token,
    );
  }

  // Manual dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      name: json['name']?.toString(),
      token: json['token']?.toString() ?? '',
    );
  }

  // Manual ke JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'username': username,
      'name': name,
      'token': token,
    };
  }

  // Buat salinan dengan update field tertentu
  UserModel copyWith({
    String? userId,
    String? email,
    String? username,
    String? name,
    String? token,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      token: token ?? this.token,
    );
  }
}
