import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board.dart';
import 'board_usecase_provider.dart';

class BoardNotifier extends AsyncNotifier<List<Board>> {
  @override
  Future<List<Board>> build() async {
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
    
    // We can show a loading state if we want, or just wait for the result
    final result = await useCase(title: title, description: description);

    result.fold(
      (failure) => null, // Handle error if needed
      (newBoard) {
        // Optimistic update or just refresh the list
        ref.invalidateSelf();
      },
    );
  }
}

final boardNotifierProvider = AsyncNotifierProvider<BoardNotifier, List<Board>>(() {
  return BoardNotifier();
});
