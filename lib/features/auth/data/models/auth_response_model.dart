import '../../domain/entities/auth_session.dart';

class AuthResponseModel extends AuthSession {
  const AuthResponseModel({
    required super.userId,
    required super.token,
    required super.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      userId: json['id'] as String,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  AuthSession toEntity() {
    return AuthSession(
      userId: userId,
      token: token,
      expiresAt: expiresAt,
    );
  }

  factory AuthResponseModel.fromEntity(AuthSession entity) {
    return AuthResponseModel(
      userId: entity.userId,
      token: entity.token,
      expiresAt: entity.expiresAt,
    );
  }
}
