import '../../../../core/fake_data/fake_database.dart';
import '../models/board_model.dart';
import 'board_remote_datasource.dart';

class FakeBoardDataSource implements BoardRemoteDataSource {
  final FakeDatabase? database;

  FakeBoardDataSource(this.database);

  @override
  Future<List<BoardModel>> getBoards() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return database?.boards.map((e) => BoardModel.fromEntity(e)).toList() ?? [];
  }

  @override
  Future<BoardModel> createBoard({
    required String title,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newBoard = BoardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      ownerId: 'user1',
      columns: [],
      members: [],
    );
    database?.boards.add(newBoard);
    return newBoard;
  }

  @override
  Future<void> deleteBoard(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    database?.boards.removeWhere((b) => b.id == id);
  }
}
