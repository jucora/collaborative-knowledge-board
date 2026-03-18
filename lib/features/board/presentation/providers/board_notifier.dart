import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/board.dart';
import 'board_usecase_provider.dart';

class BoardNotifier extends AsyncNotifier<List<Board>> {
  @override
  Future<List<Board>> build() async {
    // 🔹 IMPORTANTE: Escuchamos el estado de autenticación.
    // Si el usuario cambia (Login/Logout), este provider se invalidará 
    // automáticamente y volverá a pedir los datos del servidor.
    ref.watch(authNotifierProvider);

    final useCase = ref.watch(getBoardsUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (boards) => boards,
    );
  }

  Future<void> createBoard({
    required String title,
    required String description,
  }) async {
    final useCase = ref.read(createBoardUseCaseProvider);
    
    final result = await useCase(title: title, description: description);

    result.fold(
      (failure) => null,
      (newBoard) {
        ref.invalidateSelf();
      },
    );
  }
}

final boardNotifierProvider = AsyncNotifierProvider<BoardNotifier, List<Board>>(() {
  return BoardNotifier();
});
