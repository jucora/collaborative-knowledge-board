import 'package:collaborative_knowledge_board/features/board_column/data/datasources/fake_board_column_datasource.dart';
import 'package:collaborative_knowledge_board/features/board_column/domain/entities/board_column.dart';
import 'package:collaborative_knowledge_board/features/board_column/domain/repositories/board_column_repository.dart';
import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class FakeBoardColumnRepositoryImpl implements BoardColumnRepository {

  final FakeBoardColumnDatasource datasource;
  late List<BoardColumn> columns = [];

  FakeBoardColumnRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, List<BoardColumn>>> getBoardColumns(String boardId) async {
    columns = await datasource.getColumnsByBoard(boardId) ?? [];
    try {
      return Right(columns);
    } catch (e) {
      return Left('Failed to load board columns' as Failure);
    }
  }

  @override
  Future<Either<Failure, BoardColumn>> createBoardColumn({
    required String id,
    required String boardId,
    required String title,
    required int position,
    required List<CardItem> cards,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final newBoardColumn = BoardColumn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        boardId: 'board1',
        title: title,
        position: columns.length,
        cards: [],
      );

      columns.add(newBoardColumn);

      return Right(newBoardColumn);
    } catch (e) {
      return const Left(ServerFailure('Failed to create board column'));
    }
  }

  @override
  Future<void> updateBoardColumn({
    required String id,
    required String boardId,
    required String title,
    required int position,
    required List<CardItem> cards}) {
    // TODO: implement updateBoardColumn
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteBoardColumn(String boardId, String columnId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = columns.indexWhere((b) => b.id == columnId);

      if (index == -1) {
        return const Left(ServerFailure('Board column not found'));
      }

      columns.removeAt(index);

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete board column'));
    }
  }
}