import '../../domain/entities/auth_session.dart';

class AuthResponseModel {
  final String id;
  final String token;
  final DateTime expiresAt; // ISO String desde backend

  AuthResponseModel({
    required this.id,
    required this.token,
    required this.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'],
      token: json['token'],
      expiresAt: json['expires_at'],
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      userId: id,
      token: token,
      expiresAt: expiresAt,
    );
  }
}