import 'package:collaborative_knowledge_board/features/board_column/domain/usecases/get_board_columns_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/delete_board_column_usecase.dart';
import 'fake_board_column_providers.dart';

/// Get Board Columns Use Case Provider
final getBoardColumnsUseCaseProvider =
Provider<GetBoardColumnsUseCase>((ref) {
  final repository = ref.read(boardColumnRepositoryProvider);
  return GetBoardColumnsUseCase(repository);
});

// Delete Board Column Use Case Provider
final deleteBoardColumnProvider = Provider<DeleteBoardColumnUseCase>((ref) {
  final repository = ref.read(boardColumnRepositoryProvider);
  return DeleteBoardColumnUseCase(repository);
});