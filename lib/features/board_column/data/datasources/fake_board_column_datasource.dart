import '../../../../core/fake_data/fake_database.dart';
import '../../domain/entities/board_column.dart';

class FakeBoardColumnDatasource {

  final FakeDatabase? database;

  FakeBoardColumnDatasource(this.database);

  Future<List<BoardColumn>?> getColumnsByBoard(String boardId) async {
    final columns = database?.columns
        .where((c) => c.boardId == boardId)
        .toList();

    return columns;
  }
}