import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/board.dart';
import '../repositories/board_repository.dart';

class CreateBoardUseCase {
  final BoardRepository repository;

  CreateBoardUseCase(this.repository);

  Future<Either<Failure, Board>> call({
    required String title,
    required String description,
  }) {
    return repository.createBoard(
      title: title,
      description: description,
    );
  }
}