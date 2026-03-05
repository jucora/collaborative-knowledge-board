/// Clase base para representar errores del dominio.
///
/// Nunca exponemos excepciones técnicas a la UI.
/// En su lugar convertimos todo en Failures.
abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Error relacionado con el servidor (500, 400, etc).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Error cuando no hay conexión a internet.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Error de autenticación (401, 403).
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Error cuando ocurre algo inesperado.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// Error relacionado con almacenamiento local.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}