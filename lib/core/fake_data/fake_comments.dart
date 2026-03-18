import '../../features/card/domain/entities/card_item.dart';
import '../../features/comment/domain/entities/comment.dart';
import '../../features/user/entities/user.dart';
import 'fake_users.dart';

class FakeComments {
  static List<Comment> generate({
    required List<CardItem> cards,
    required List<User> users,
  }) {
    final comments = <Comment>[];

    for (final card in cards) {
      for (int i = 0; i < 3; i++) {
        final user = users[i % users.length];

        comments.add(
          Comment(
            id: '${card.id}_comment_$i',
            cardId: card.id,
            authorId: user.id,
            content: faker.lorem.sentence(),
            createdAt: DateTime.now().subtract(Duration(minutes: i * 5)),
          ),
        );
      }
    }

    return comments;
  }
}