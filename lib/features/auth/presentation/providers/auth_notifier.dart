import 'package:collaborative_knowledge_board/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          (user) => AsyncData(user),
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();

    final result = await _registerUseCase(email, password);

    state = result.fold(
          (failure) => AsyncError(failure, StackTrace.current),
          (user) => AsyncData(user),
    );
  }
}