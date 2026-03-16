import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import 'comment_remote_datasource.dart';

class SupabaseCommentDataSourceImpl implements CommentRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<CommentModel>> getComments(String cardId) async {
    final response = await _client
        .from('comments')
        .select()
        .eq('cardId', cardId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => CommentModel.fromJson(json))
        .toList();
  }

  @override
  Future<CommentModel> addComment(CommentModel comment) async {
    final response = await _client
        .from('comments')
        .insert(comment.toJson())
        .select()
        .single();

    return CommentModel.fromJson(response);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }
}
