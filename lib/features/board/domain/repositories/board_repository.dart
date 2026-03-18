import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/board.dart';

abstract class BoardRepository {
  Future<Either<Failure, List<Board>>> getBoards();

  Future<Either<Failure, Board>> createBoard({
    required String title,
    required String description,
  });

  Future<Either<Failure, void>> deleteBoard(String boardId);
}