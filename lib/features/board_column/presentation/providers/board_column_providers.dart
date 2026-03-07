import 'package:collaborative_knowledge_board/features/board_column/domain/usecases/get_board_columns_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/usecases/delete_board_column_usecase.dart';
import 'fake_board_column_repository_provider.dart';

final getBoardColumnsUseCaseProviderInternal =
Provider<GetBoardColumnsUseCase>((ref) {

  final repository = ref.read(boardColumnRepositoryProvider);

  return GetBoardColumnsUseCase(repository);
});

final getBoardColumnsUseCaseProvider =
FutureProvider.family<List<BoardColumn>, String>((ref, boardId) async {

  final useCase = ref.read(getBoardColumnsUseCaseProviderInternal);

  final result = await useCase(boardId);

  return result.fold(
        (failure) => throw failure,
        (columns) => columns,
  );
});

// Delete Board Column Use Case Provider
final deleteBoardColumnProvider = Provider<DeleteBoardColumnUseCase>((ref) {
  final repository = ref.read(boardColumnRepositoryProvider);
  return DeleteBoardColumnUseCase(repository);
});