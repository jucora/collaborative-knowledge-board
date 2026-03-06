import 'package:collaborative_knowledge_board/features/board_column/data/repositories/fake_board_column_repository_impl.dart';
import 'package:collaborative_knowledge_board/features/board_column/domain/repositories/board_column_repository.dart';
import 'package:collaborative_knowledge_board/features/board_column/domain/usecases/get_board_columns_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/usecases/delete_board_column_usecase.dart';
import 'board_column_notifier.dart';

// Board Columns Notifier Provider
final boardColumnsProvider =
AsyncNotifierProvider.family<
    BoardColumnNotifier,
    List<BoardColumn>,
    String>(
  BoardColumnNotifier.new,
);

/// BoardColumn Repository Provider
final boardColumnRepositoryProvider =
Provider<BoardColumnRepository>((ref) {

  if (useFake) {
    return FakeBoardColumnRepositoryImpl();
  }
  return throw UnimplementedError(
    'Implement AuthRepository when using a real API',
  );
});

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