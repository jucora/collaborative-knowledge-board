import '../../../../core/fake_data/fake_database.dart';
import '../../domain/entities/comment.dart';

class FakeCommentDataSource {

  final FakeDatabase database;

  FakeCommentDataSource(this.database);

  Future<List<Comment>> getCommentsByCard(String cardId) async {

    await Future.delayed(const Duration(milliseconds: 200));

    return database.comments
        .where((c) => c.cardId == cardId)
        .toList();

  }

  Future<void> addComments(List<Comment> comments) async {
    for (var comment in comments) {
      database.comments.add(comment);
    }
  }
}