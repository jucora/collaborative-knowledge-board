import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Interceptor responsable de:
/// - Inyectar el JWT en cada request
/// - Detectar errores 401
/// - Manejar comportamiento global de autenticación
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  /// Se ejecuta antes de que la request salga.
  /// Aquí agregamos el token si existe.
  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _secureStorage.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  /// Se ejecuta cuando ocurre un error.
  /// Ideal para detectar expiración de token.
  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    if (err.response?.statusCode == 401) {
      // Token inválido o expirado.
      await _secureStorage.clearToken();

      // Aquí podrías emitir un evento global de logout
      // usando un provider o un stream global.
    }

    handler.next(err);
  }
}