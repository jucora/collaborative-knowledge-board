import 'package:collaborative_knowledge_board/features/board_column/domain/entities/board_column.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/board_column_repository.dart';

class GetBoardColumnsUseCase {
  final BoardColumnRepository repository;

  GetBoardColumnsUseCase(this.repository);

  Future<Either<Failure, List<BoardColumn>>> call(String boardId) {
    return repository.getBoardColumns(boardId);
  }
}