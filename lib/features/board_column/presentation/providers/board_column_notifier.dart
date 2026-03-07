import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/usecases/get_board_columns_usecase.dart';
import 'board_column_usecase_provider.dart';

class BoardColumnNotifier extends FamilyAsyncNotifier<List<BoardColumn>, String> {

  late final GetBoardColumnsUseCase getBoardColumns;

  @override
  Future<List<BoardColumn>> build(String boardId) async {

    getBoardColumns = ref.read(getBoardColumnsUseCaseProvider);

    final result = await getBoardColumns(boardId);

    return result.fold(
          (failure) => throw failure,
          (boardColumns) => boardColumns,
    );
  }

  Future<void> refreshBoardColumns(String boardId) async {
    state = const AsyncLoading<List<BoardColumn>>().copyWithPrevious(state);

    final result = await getBoardColumns(boardId);

    result.fold(
          (failure) => state = AsyncError(failure, StackTrace.current),
          (columns) => state = AsyncData(columns),
    );
  }

  Future<void> deleteBoardColumn(
      String boardId,
      String columnId,
      ) async {

    final deleteBoardColumn = ref.read(deleteBoardColumnProvider);

    final result = await deleteBoardColumn(boardId, columnId);

    result.fold(
          (failure) {
        // manejar error
      },
          (_) {
        state = state.whenData(
              (columns) => columns.where((c) => c.id != columnId).toList(),
        );
      },
    );
  }
}