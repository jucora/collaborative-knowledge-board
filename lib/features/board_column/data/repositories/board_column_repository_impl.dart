import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/repositories/board_column_repository.dart';
import '../datasources/board_column_remote_datasource.dart';

class BoardColumnRepositoryImpl implements BoardColumnRepository {

  final BoardColumnRemoteDataSource remoteDataSource;

  BoardColumnRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createBoardColumn({
    required String id,
    required String boardId,
    required String title,
    required int position,
    required List<CardItem> cards
  }) {
    // TODO: implement createBoardColumn
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteBoardColumn(String boardId, String columnId) {
    // TODO: implement deleteBoardColumn
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<BoardColumn>>> getBoardColumns(String boardId) {
    // TODO: implement getBoardColumns
    throw UnimplementedError();
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


}