import 'package:dartz/dartz.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/board_remote_datasource.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardRemoteDataSource remoteDataSource;

  BoardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Board>>> getBoards() async {
    try {
      final models = await remoteDataSource.getBoards();
      return Right(models.map((e) => e.toEntity()).toList());
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Board>> createBoard({
    required String title,
    required String description,
  }) async {
    try {
      final model = await remoteDataSource.createBoard(
        title: title,
        description: description,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBoard(String id) async {
    try {
      await remoteDataSource.deleteBoard(id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }
}