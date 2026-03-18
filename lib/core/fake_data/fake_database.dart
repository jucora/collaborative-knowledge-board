import '../../features/board/domain/entities/board.dart';
import '../../features/board_member/domain/entities/board_member.dart';
import '../../features/board_column/domain/entities/board_column.dart';
import '../../features/card/domain/entities/card_item.dart';
import '../../features/comment/domain/entities/comment.dart';
import '../../features/user/entities/user.dart';

class FakeDatabase {
  final List<User> users;
  final List<Board> boards;
  final List<BoardMember> members;
  final List<BoardColumn> columns;
  final List<CardItem> cards;
  final List<Comment> comments;

  const FakeDatabase({
    required this.users,
    required this.boards,
    required this.members,
    required this.columns,
    required this.cards,
    required this.comments,
  });
}