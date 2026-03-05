/// Centraliza todos los endpoints de la API.
/// Evita strings mágicos distribuidos en el proyecto.
/// Facilita mantenimiento y cambios de entorno.
class ApiEndpoints {
  ApiEndpoints._(); // Constructor privado para evitar instanciación.

  /// Base URL principal de la API.
  /// En producción esto debería venir de un config/env.
  static const String baseUrl = 'https://api.yourdomain.com';

  // =======================
  // AUTH
  // =======================

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // =======================
  // BOARDS
  // =======================

  static const String boards = '/boards';
  static String boardById(String id) => '/boards/$id';

  // =======================
  // COLUMNS
  // =======================

  static String columnsByBoard(String boardId) =>
      '/boards/$boardId/columns';

  // =======================
  // CARDS
  // =======================

  static String cardsByColumn(String columnId) =>
      '/columns/$columnId/cards';

  static String cardById(String id) => '/cards/$id';
}