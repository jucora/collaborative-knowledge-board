import 'package:collaborative_knowledge_board/features/board_column/domain/entities/board_column.dart';
import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class BoardColumnRepository {

  Future<Either<Failure, List<BoardColumn>>> getBoardColumns(String boardId);

  Future<void> createBoardColumn({
    required String id,
    required String boardId,
    required String title,
    required int position,
    required List<CardItem> cards,
  });

  Future<void> updateBoardColumn({
    required String id,
    required String boardId,
    required String title,
    required int position,
    required List<CardItem> cards,
  });

  Future<Either<Failure, void>>deleteBoardColumn(String boardId, String columnId);
}