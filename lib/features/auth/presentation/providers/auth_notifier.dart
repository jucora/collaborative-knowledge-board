import 'package:collaborative_knowledge_board/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import 'auth_providers.dart';

class AuthNotifier extends AsyncNotifier<AuthSession?> {

  // here the provider is consume to get the use cases
  late final _loginUseCase =
  ref.read(loginUseCaseProvider);

  late final _registerUseCase =
  ref.read(registerUseCaseProvider);

  @override
  Future<AuthSession?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    final result = await _loginUseCase(email, password);

    state = result.fold(
          (failure) => AsyncError(failure, StackTrace.current),
          (user) {
            // In a real app, the use case or repository should handle token storage.
            // For now, we'll ensure the token is saved so the router works.
            ref.read(secureStorageProvider).saveToken('fake-token');
            return AsyncData(user);
          },
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();

    final result = await _registerUseCase(email, password);

    state = result.fold(
          (failure) => AsyncError(failure, StackTrace.current),
          (user) {
            ref.read(secureStorageProvider).saveToken('fake-token');
            return AsyncData(user);
          },
    );
  }

  /// LOGOUT Implementation
  /// Clears both the local state and the persistent secure storage.
  Future<void> logout() async {
    state = const AsyncLoading();
    
    // 1. Clear persistent token so the Router redirect works correctly
    await ref.read(secureStorageProvider).clearToken();
    
    // 2. Clear local state
    state = const AsyncData(null);
  }
}
