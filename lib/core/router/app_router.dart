import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/board/presentation/pages/board_dashboard_page.dart';
import '../../features/board/presentation/pages/board_detail_page.dart';
import '../storage/secure_storage_service.dart';

/// Provider del router.
/// Permite acceso global e integración con Riverpod.
final appRouterProvider = Provider<GoRouter>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  return GoRouter(
    initialLocation: '/login',

    /// Redirección global.
    /// Se ejecuta antes de cada navegación.
    redirect: (context, state) async {
      final hasToken = await secureStorage.hasToken();

      final isAuthRoute =
          state.matchedLocation == '/login' ||
              state.matchedLocation == '/register';

      // Si NO está autenticado y quiere ir a ruta protegida
      if (!hasToken && !isAuthRoute) {
        return '/login';
      }

      // Si ya está autenticado y quiere ir a login/register
      if (hasToken && isAuthRoute) {
        return '/boards';
      }

      return null; // No redirigir
    },

    routes: [
      // =========================
      // AUTH ROUTES
      // =========================

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // =========================
      // BOARD DASHBOARD
      // =========================

      GoRoute(
        path: '/boards',
        name: 'boards',
        builder: (context, state) => const BoardDashboardPage(),
        routes: [
          // =========================
          // BOARD DETAIL (Nested)
          // =========================
          GoRoute(
            path: ':boardId',
            name: 'boardDetail',
            builder: (context, state) {
              final boardId = state.pathParameters['boardId']!;
              return BoardDetailPage(boardId: boardId);
            },
          ),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
        ),
      ),
    ),
  );
});