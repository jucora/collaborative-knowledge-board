import 'package:collaborative_knowledge_board/features/board/data/datasources/fake_board_datasource.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';

class FakeBoardRepositoryImpl implements BoardRepository {

  List<Board> boards = [];

  FakeBoardRepositoryImpl(FakeBoardDataSource datasource) {
    boards = datasource.database?.boards ?? [];
  }

  @override
  Future<Either<Failure, List<Board>>> getBoards() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return Right(List.unmodifiable(boards));
    } catch (e) {
      return const Left(ServerFailure('Failed to load boards'));
    }
  }

  @override
  Future<Either<Failure, Board>> createBoard({
    required String title,
    required String description,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final newBoard = Board(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
        ownerId: 'user1',
        columns: [],
        members: [],
      );

      boards.add(newBoard);

      return Right(newBoard);
    } catch (e) {
      return const Left(ServerFailure('Failed to create board'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBoard(String boardId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = boards.indexWhere((b) => b.id == boardId);

      if (index == -1) {
        return const Left(ServerFailure('Board not found'));
      }

      boards.removeAt(index);

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete board'));
    }
  }
}