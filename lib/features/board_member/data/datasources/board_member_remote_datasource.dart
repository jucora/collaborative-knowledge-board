import 'package:collaborative_knowledge_board/features/board_member/data/models/board_member_model.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

class BoardMemberRemoteDatasource {
  final DioClient dioClient;

  BoardMemberRemoteDatasource(this.dioClient);

  Future<List<BoardMemberModel>> getBoardMembers(String boardId) async {
    final response = await dioClient.get(ApiEndpoints.membersByBoard(boardId));

    final List data = response.data;

    return data
        .map((json) => BoardMemberModel.fromJson(json))
        .toList();
  }

  Future<BoardMemberModel> addBoardMember({
    required String boardId,
    required String userId,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.membersByBoard(boardId),
      data: {
        'userId': userId,
      },
    );

    return BoardMemberModel.fromJson(response.data);
  }

  Future<void> removeBoardMember({
    required String boardId,
    required String userId,
  }) async {
    await dioClient.delete(ApiEndpoints.memberByBoardAndUser(boardId, userId));
  }
}