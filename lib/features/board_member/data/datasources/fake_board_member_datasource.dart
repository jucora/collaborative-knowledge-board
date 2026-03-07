import 'package:collaborative_knowledge_board/core/fake_data/fake_database.dart';
import '../../domain/entities/board_member.dart';

class FakeBoardMemberDatasource {

  final FakeDatabase database;

  FakeBoardMemberDatasource(this.database);

  Future<List<BoardMember>> getBoardMembers(String boardId) async {
    final members = database.members
        .where((m) => m.boardId == boardId)
        .toList();
    return members;
  }

  // Add member to board

  Future<void> addMemberToBoard(BoardMember member) async {
    database.members.add(member);
  }

  // Remove member from board
  Future<void> removeMemberFromBoard(String boardId, String userId) async {
    database.members.removeWhere((m) =>
    m.boardId == boardId && m.userId == userId);
  }
}