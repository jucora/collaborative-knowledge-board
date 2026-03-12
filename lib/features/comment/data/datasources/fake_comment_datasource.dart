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

  Future<void> addComment(Comment comment) async {
    database.comments.add(comment);
  }

  Future<void> updateComment(Comment comment) async {
    final index = database.comments.indexWhere((c) => c.id == comment.id);
    if (index != -1) {
      database.comments[index] = comment;
    } else {
      throw Exception('Comment not found');
    }
  }

  Future<void> deleteComment(String commentId) async {
    // To maintain scalability and referential integrity in a real DB, 
    // we might do a soft delete or handle children. 
    // For this fake, we remove the comment and its direct replies.
    database.comments.removeWhere((c) => c.id == commentId || c.parentId == commentId);
  }

  Future<void> addComments(List<Comment> comments) async {
    database.comments.addAll(comments);
  }
}
