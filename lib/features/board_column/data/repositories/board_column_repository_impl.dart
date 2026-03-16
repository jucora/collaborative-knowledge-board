import 'package:dartz/dartz.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../datasources/board_column_remote_datasource.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/repositories/board_column_repository.dart';
import '../models/board_column_model.dart';

class BoardColumnRepositoryImpl implements BoardColumnRepository {
  final BoardColumnRemoteDataSource remoteDataSource;

  BoardColumnRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BoardColumn>>> getBoardColumns(String boardId) async {
    try {
      final models = await remoteDataSource.getBoardColumns(boardId);
      return Right(models);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, BoardColumn>> createBoardColumn({
    required String boardId,
    required String title,
    required int position,
  }) async {
    try {
      final model = await remoteDataSource.createBoardColumn(
        boardId: boardId,
        title: title,
        position: position,
      );
      return Right(model);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateBoardColumn(BoardColumn column) async {
    try {
      await remoteDataSource.updateBoardColumn(
        BoardColumnModel.fromEntity(column),
      );
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBoardColumn(String columnId) async {
    try {
      await remoteDataSource.deleteBoardColumn(columnId);
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }
}
