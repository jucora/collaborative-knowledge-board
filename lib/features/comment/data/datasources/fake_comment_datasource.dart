import '../../../../core/fake_data/fake_database.dart';
import '../models/comment_model.dart';
import 'comment_remote_datasource.dart';

class FakeCommentDataSource implements CommentRemoteDataSource {
  final FakeDatabase database;

  FakeCommentDataSource(this.database);

  @override
  Future<List<CommentModel>> getComments(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final comments = database.comments
        .where((c) => c.cardId == cardId)
        .toList();
    
    return comments.map((e) => CommentModel.fromEntity(e)).toList();
  }

  @override
  Future<CommentModel> addComment(CommentModel comment) async {
    await Future.delayed(const Duration(milliseconds: 300));
    database.comments.add(comment);
    return comment is CommentModel ? comment : CommentModel.fromEntity(comment);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    database.comments.removeWhere((c) => c.id == commentId || c.parentId == commentId);
  }

  @override
  Future<void> updateComment(CommentModel comment) async{
    await Future.delayed(const Duration(milliseconds: 300));
    final index = database.comments.indexWhere((c) => c.id == comment.id);
    if (index != -1) {
      database.comments[index] = comment;
    }
    return Future.value();
  }
}
