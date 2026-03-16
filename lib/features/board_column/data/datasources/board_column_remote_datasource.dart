import '../models/board_column_model.dart';

abstract class BoardColumnRemoteDataSource {
  Future<List<BoardColumnModel>> getBoardColumns(String boardId);

  Future<BoardColumnModel> createBoardColumn({
    required String boardId,
    required String title,
    required int position,
  });

  Future<void> updateBoardColumn(BoardColumnModel column);

  Future<void> deleteBoardColumn(String id);
}
