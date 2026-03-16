import '../models/board_model.dart';

abstract class BoardRemoteDataSource {
  Future<List<BoardModel>> getBoards();

  Future<BoardModel> createBoard({
    required String title,
    required String description,
  });

  Future<void> deleteBoard(String id);
}
