import 'fake_board_members.dart';
import 'fake_boards.dart';
import 'fake_cards.dart';
import 'fake_columns.dart';
import 'fake_comments.dart';
import 'fake_database.dart';
import 'fake_users.dart';

class FakeDataGenerator {
  static FakeDatabase generate() {
    final users = FakeUsers.generate();
    final boards = FakeBoards.generate(boardMembers: users);
    final members = FakeBoardMembers.generate(users: users, boards: boards);
    final columns = FakeColumns.generate(boards: boards);
    final cards = FakeCards.generate(columns: columns);
    final comments = FakeComments.generate(cards: cards, users: users);

    return FakeDatabase(
      users: users,
      boards: boards,
      members: members,
      columns: columns,
      cards: cards,
      comments: comments,
    );
  }
}