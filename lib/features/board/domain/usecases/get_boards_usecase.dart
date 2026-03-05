import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/board.dart';
import '../repositories/board_repository.dart';

class GetBoardsUseCase {
  final BoardRepository repository;

  GetBoardsUseCase(this.repository);

  Future<Either<Failure, List<Board>>> call() {
    return repository.getBoards();
  }
}