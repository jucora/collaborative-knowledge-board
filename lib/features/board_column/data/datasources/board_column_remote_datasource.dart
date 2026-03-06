import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/board_column_model.dart';

class BoardColumnRemoteDataSource {
  final DioClient dioClient;

  BoardColumnRemoteDataSource(this.dioClient);

  Future<List<BoardColumnModel>> getBoardColumns(String boardId) async {
    final response = await dioClient.get(ApiEndpoints.columnsByBoard(boardId));

    final List data = response.data;

    return data
        .map((json) => BoardColumnModel.fromJson(json))
        .toList();
  }

  Future<BoardColumnModel> createBoard({
    required String title,
    required String description,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.boards,
      data: {
        'title': title,
        'description': description,
      },
    );

    return BoardColumnModel.fromJson(response.data);
  }

  Future<void> deleteBoardColumn(String id) async {
    await dioClient.delete(ApiEndpoints.columnById(id));
  }
}