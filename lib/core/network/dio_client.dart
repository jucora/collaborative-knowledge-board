import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage_service.dart';

/// Cliente HTTP centralizado.
/// Toda la app debe usar esta instancia.
///
/// Evita crear Dio en cada repositorio.
/// Garantiza configuración consistente.
class DioClient {
  late final Dio _dio;

  DioClient(SecureStorageService secureStorageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,

        /// Tiempo máximo de espera para conexión.
        connectTimeout: const Duration(seconds: 10),

        /// Tiempo máximo para recibir respuesta.
        receiveTimeout: const Duration(seconds: 10),

        /// Headers base globales.
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // ==========================
    // Interceptors
    // ==========================

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorageService),

      /// Logging interceptor (solo en debug idealmente)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  /// GET
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
    );
  }

  /// POST
  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// PUT
  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
      }) async {
    return _dio.put<T>(
      path,
      data: data,
    );
  }

  /// DELETE
  Future<Response<T>> delete<T>(
      String path,
      ) async {
    return _dio.delete<T>(path);
  }
}