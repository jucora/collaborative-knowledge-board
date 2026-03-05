import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ------------------------------------------------------------
/// PROVIDER
/// ------------------------------------------------------------
/// Expone SecureStorageService a toda la aplicación.
/// Permite inyección de dependencias y testeo.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// ------------------------------------------------------------
/// SERVICE
/// ------------------------------------------------------------
/// Servicio responsable de manejar almacenamiento seguro.
///
/// Cumple SRP:
/// Solo maneja almacenamiento de token.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Constructor con posibilidad de inyección (útil para testing).
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  /// Guarda el JWT
  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  /// Obtiene el JWT
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina el token
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Verifica si existe token
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }
}