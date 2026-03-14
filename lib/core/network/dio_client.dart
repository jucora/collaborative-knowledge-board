import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  late final Dio _dio;

  DioClient(SecureStorageService secureStorageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,

        connectTimeout: const Duration(seconds: 10),

        receiveTimeout: const Duration(seconds: 10),

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