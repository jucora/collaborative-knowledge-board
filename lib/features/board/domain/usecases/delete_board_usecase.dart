import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/board_repository.dart';

class DeleteBoardUseCase {
  final BoardRepository repository;

  DeleteBoardUseCase(this.repository);

  Future<Either<Failure, void>> call(String boardId) {
    return repository.deleteBoard(boardId);
  }
}