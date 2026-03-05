import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/board_model.dart';

class BoardRemoteDataSource {
  final DioClient dioClient;

  BoardRemoteDataSource(this.dioClient);

  Future<List<BoardModel>> getBoards() async {
    final response = await dioClient.get(ApiEndpoints.boards);

    final List data = response.data;

    return data
        .map((json) => BoardModel.fromJson(json))
        .toList();
  }

  Future<BoardModel> createBoard({
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

    return BoardModel.fromJson(response.data);
  }

  Future<void> deleteBoard(String id) async {
    await dioClient.delete(ApiEndpoints.boardById(id));
  }
}