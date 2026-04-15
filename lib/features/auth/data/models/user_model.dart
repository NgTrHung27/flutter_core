import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.email,
    required super.username,
    required super.password,
    super.token,
    super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Expected json is the 'data' field from the response
    final user = json['user'] as Map<String, dynamic>?;
    return UserModel(
      userId: user?['userId']?.toString() ?? '',
      email: user?['email'] ?? '',
      username: user?['username'] ?? '',
      password: '', // Password is not returned from API
      token: json['token'],
      refreshToken: json['refreshToken'],
    );
  }
}
