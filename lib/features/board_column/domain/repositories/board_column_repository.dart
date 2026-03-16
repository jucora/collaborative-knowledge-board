import 'package:collaborative_knowledge_board/features/board_column/domain/entities/board_column.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class BoardColumnRepository {
  Future<Either<Failure, List<BoardColumn>>> getBoardColumns(String boardId);

  Future<Either<Failure, BoardColumn>> createBoardColumn({
    required String boardId,
    required String title,
    required int position,
  });

  Future<Either<Failure, void>> updateBoardColumn(BoardColumn column);

  Future<Either<Failure, void>> deleteBoardColumn(String columnId);
}
