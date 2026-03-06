import 'package:collaborative_knowledge_board/features/board_column/domain/entities/board_column.dart';
import 'package:collaborative_knowledge_board/features/board_column/domain/repositories/board_column_repository.dart';
import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../../../core/fake_data/fake_database.dart';

class FakeBoardColumnRepositoryImpl implements BoardColumnRepository {

  late final FakeDatabase _db;

  FakeBoardRepositoryImpl() {
    _db = FakeDataGenerator.generate();
  }

  @override
  Future<Either<Failure, List<BoardColumn>>> getBoardColumns(boardId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return Right(List.unmodifiable(_db.columns));
    } catch (e) {
      return Left(ServerFailure('Failed to load board columns'));
    }
  }

  @override
  Future<Either<Failure, BoardColumn>> createBoardColumn({
    required String id,
    required String boardId,
    required String title,
    required int position,
    required List<CardItem> cards,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final newBoardColumn = BoardColumn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        boardId: 'board1',
        title: title,
        position: _db.columns.length,
        cards: [],
      );

      _db.columns.add(newBoardColumn);

      return Right(newBoardColumn);
    } catch (e) {
      return Left(ServerFailure('Failed to create board column'));
    }
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

  @override
  Future<Either<Failure, void>> deleteBoardColumn(String boardId, String columnId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final index = _db.columns.indexWhere((b) => b.id == columnId);

      if (index == -1) {
        return Left(ServerFailure('Board column not found'));
      }

      _db.columns.removeAt(index);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete board column'));
    }
  }
}