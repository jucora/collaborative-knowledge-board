import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';

class BoardNotifier extends AsyncNotifier<List<Board>> {
  late final BoardRepository repository;

  BoardNotifier(this.repository);

  @override
  Future<List<Board>> build() async {
    final result = await repository.getBoards();

    return result.fold(
          (failure) => throw failure,
          (boards) => boards,
    );
  }

  Future<void> refreshBoards() async {
    state = const AsyncLoading();

    final result = await repository.getBoards();

    state = result.fold(
          (failure) => AsyncError(failure, StackTrace.current),
          (boards) => AsyncData(boards),
    );
  }

  Future<void> deleteBoard(String boardId) async {
    final result = await repository.deleteBoard(boardId);

    result.fold(
          (failure) {},
          (_) async {
        await refreshBoards();
      },
    );
  }
}