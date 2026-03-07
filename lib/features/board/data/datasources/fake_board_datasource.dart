import '../../../../core/fake_data/fake_database.dart';
import '../../domain/entities/board.dart';

class FakeBoardDataSource {

  final FakeDatabase? database;

  FakeBoardDataSource(this.database);

  Future<List<Board>?> getBoards() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return database?.boards;
  }
}