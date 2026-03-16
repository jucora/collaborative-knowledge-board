import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/board_column.dart';
import '../repositories/board_column_repository.dart';

class CreateBoardColumnUseCase {
  final BoardColumnRepository repository;

  CreateBoardColumnUseCase(this.repository);

  Future<Either<Failure, BoardColumn>> call({
    required String boardId,
    required String title,
    required int position,
  }) {
    return repository.createBoardColumn(
      boardId: boardId,
      title: title,
      position: position,
    );
  }
}
