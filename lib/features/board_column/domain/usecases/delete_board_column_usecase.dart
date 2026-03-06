import 'package:collaborative_knowledge_board/features/board_column/domain/repositories/board_column_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class DeleteBoardColumnUseCase {
  final BoardColumnRepository repository;

  DeleteBoardColumnUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String boardId,
      String columnId,
      ) {
    return repository.deleteBoardColumn(boardId, columnId);
  }
}