import '../../features/board/domain/entities/board.dart';
import '../../features/board_member/domain/entities/board_member.dart';
import '../../features/user/entities/user.dart';

class FakeBoardMembers {
  static List<BoardMember> generate({
    required List<User> users,
    required List<Board> boards,
  }) {
    final members = <BoardMember>[];

    for (final board in boards) {
      for (final user in users.take(3)) {
        members.add(
          BoardMember(
            userId: '${board.id}_${user.id}',
            boardId: board.id,
            role: 'member',
            joinedAt: DateTime.now().subtract(Duration(days: 30)),
          ),
        );
      }
    }

    return members;
  }
}