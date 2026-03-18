import 'dart:io';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'failures.dart';

class ExceptionHandler {
  static Failure handle(Object error) {
    if (error is AuthException) {
      return AuthFailure(error.message);
    }

    if (error is PostgrestException) {
      return ServerFailure(error.message);
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is SocketException) {
      return const NetworkFailure(
        'No internet connection.',
      );
    }

    return const UnexpectedFailure(
      'Unexpected error occurred.',
    );
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure(
          'Connection timeout. Please try again.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        if (statusCode == 401 || statusCode == 403) {
          return const AuthFailure(
            'Unauthorized access.',
          );
        }

        return ServerFailure(
          error.response?.data['message'] ??
              'Server error occurred.',
        );

      case DioExceptionType.cancel:
        return const UnexpectedFailure('Request cancelled.');

      default:
        return const UnexpectedFailure(
          'Something went wrong.',
        );
    }
  }
}
