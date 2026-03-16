import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/usecases/get_board_columns_usecase.dart';
import 'board_column_usecase_provider.dart';

class BoardColumnNotifier extends FamilyAsyncNotifier<List<BoardColumn>, String> {
  late String boardId;

  @override
  Future<List<BoardColumn>> build(String arg) async {
    boardId = arg;
    final getBoardColumns = ref.read(getBoardColumnsUseCaseProvider);
    final result = await getBoardColumns(boardId);

    return result.fold(
      (failure) => throw failure,
      (boardColumns) => boardColumns,
    );
  }

  Future<void> createColumn(String title) async {
    final useCase = ref.read(createBoardColumnUseCaseProvider);
    
    // Get current columns to determine position
    final currentColumns = state.value ?? [];
    
    final result = await useCase(
      boardId: boardId,
      title: title,
      position: currentColumns.length,
    );

    result.fold(
      (failure) => null, // Handle error
      (newColumn) => ref.invalidateSelf(),
    );
  }

  Future<void> deleteBoardColumn(String columnId) async {
    final useCase = ref.read(deleteBoardColumnProvider);
    final result = await useCase(columnId);

    result.fold(
      (failure) => null,
      (_) => ref.invalidateSelf(),
    );
  }
}

final boardColumnNotifierProvider = AsyncNotifierProvider.family<BoardColumnNotifier, List<BoardColumn>, String>(() {
  return BoardColumnNotifier();
});
