import '../../../../core/fake_data/fake_database.dart';
import '../models/board_member_model.dart';
import 'board_member_remote_datasource.dart';

class FakeBoardMemberDatasource implements BoardMemberRemoteDataSource {
  final FakeDatabase? database;

  FakeBoardMemberDatasource(this.database);

  @override
  Future<List<BoardMemberModel>> getBoardMembers(String boardId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final members = database?.members
        .where((m) => m.boardId == boardId)
        .toList() ?? [];
    
    return members.map((e) => BoardMemberModel.fromEntity(e)).toList();
  }

  @override
  Future<BoardMemberModel> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
    required DateTime joinedAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newMember = BoardMemberModel(
      boardId: boardId,
      userId: userId,
      role: role,
      joinedAt: DateTime.now(),
    );
    database?.members.add(newMember);
    return newMember;
  }

  @override
  Future<void> removeBoardMember({
    required String boardId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    database?.members.removeWhere(
      (m) => m.boardId == boardId && m.userId == userId,
    );
  }
}
