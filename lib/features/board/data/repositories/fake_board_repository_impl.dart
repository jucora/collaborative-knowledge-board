import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../../../core/fake_data/fake_database.dart';
import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';

class FakeBoardRepositoryImpl implements BoardRepository {

  late final FakeDatabase _db;

  FakeBoardRepositoryImpl() {
    _db = FakeDataGenerator.generate();
  }


  @override
  Future<Either<Failure, List<Board>>> getBoards() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return Right(List.unmodifiable(_db.boards));
    } catch (e) {
      return Left(ServerFailure('Failed to load boards'));
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

      _db.boards.add(newBoard);

      return Right(newBoard);
    } catch (e) {
      return Left(ServerFailure('Failed to create board'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBoard(String boardId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _db.boards.indexWhere((b) => b.id == boardId);

      if (index == -1) {
        return Left(ServerFailure('Board not found'));
      }

      _db.boards.removeAt(index);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete board'));
    }
  }
}