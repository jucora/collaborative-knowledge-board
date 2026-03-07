import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board.dart';
import 'board_usecase_provider.dart';

class BoardNotifier extends AsyncNotifier<List<Board>> {

  @override
  Future<List<Board>> build() async {
    final useCase = ref.read(getBoardsUseCaseProvider);

    final result = await useCase();

    return result.fold(
          (failure) => throw failure,
          (boards) => boards,
    );
  }

  Future<void> refreshBoards() async {
    state = const AsyncLoading();

    final useCase = ref.read(getBoardsUseCaseProvider);

    final result = await useCase();

    state = result.fold(
          (failure) => AsyncError(failure, StackTrace.current),
          (boards) => AsyncData(boards),
    );
  }

  Future<void> deleteBoard(String boardId) async {
    final useCase = ref.read(deleteBoardUseCaseProvider);

    final result = await useCase(boardId);

    result.fold(
          (failure) => throw failure.message,
          (_) {
        state = state.whenData(
              (boards) => boards.where((b) => b.id != boardId).toList(),
        );
      },
    );
  }
}