import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/board/presentation/pages/board_dashboard_page.dart';
import '../../features/board/presentation/pages/board_detail_page.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  
  // A simple ValueNotifier to tell GoRouter when to refresh
  final refreshListenable = ValueNotifier<bool>(false);
  
  // We listen to the auth state. Whenever it changes, we toggle the notifier.
  ref.listen(authNotifierProvider, (previous, next) {
    refreshListenable.value = !refreshListenable.value;
  });

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    
    redirect: (context, state) async {
      final hasToken = await secureStorage.hasToken();
      final authState = ref.read(authNotifierProvider);
      final isLoggedIn = hasToken || authState.value != null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isPublicRoute = isLoggingIn || isRegistering;

      debugPrint('Router Redirect: path=${state.matchedLocation}, isLoggedIn=$isLoggedIn');

      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      if (isLoggedIn && isPublicRoute) {
        return '/boards';
      }

      return null;
    },

    routes: [
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
      GoRoute(
        path: '/boards',
        name: 'boards',
        builder: (context, state) => const BoardDashboardPage(),
        routes: [
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
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/boards'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
