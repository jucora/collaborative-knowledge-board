import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(String cardId);
  Future<CommentModel> addComment(CommentModel comment);
  Future<void> deleteComment(String commentId);
}
