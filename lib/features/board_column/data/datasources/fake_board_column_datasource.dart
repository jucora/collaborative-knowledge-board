import '../../../../core/fake_data/fake_database.dart';
import '../models/board_column_model.dart';
import 'board_column_remote_datasource.dart';

class FakeBoardColumnDatasource implements BoardColumnRemoteDataSource {
  final FakeDatabase? database;

  FakeBoardColumnDatasource(this.database);

  @override
  Future<List<BoardColumnModel>> getBoardColumns(String boardId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final columns = database?.columns
        .where((c) => c.boardId == boardId)
        .toList() ?? [];
    
    return columns.map((e) => BoardColumnModel.fromEntity(e)).toList();
  }

  @override
  Future<BoardColumnModel> createBoardColumn({
    required String boardId,
    required String title,
    required int position,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newColumn = BoardColumnModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      boardId: boardId,
      title: title,
      position: position,
      cards: [],
    );
    database?.columns.add(newColumn);
    return newColumn;
  }

  @override
  Future<void> updateBoardColumn(BoardColumnModel column) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = database?.columns.indexWhere((c) => c.id == column.id) ?? -1;
    if (index != -1) {
      database?.columns[index] = column;
    }
  }

  @override
  Future<void> deleteBoardColumn(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    database?.columns.removeWhere((c) => c.id == id);
  }
}
