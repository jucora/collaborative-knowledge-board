import '../models/board_member_model.dart';

abstract class BoardMemberRemoteDataSource {
  Future<List<BoardMemberModel>> getBoardMembers(String boardId);

  Future<BoardMemberModel> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
  });

  Future<void> removeBoardMember({
    required String boardId,
    required String userId,
  });
}
