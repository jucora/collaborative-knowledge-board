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
    final data = comment.toJson();
    data.remove('id');
    
    final response = await _client
        .from('comments')
        .insert(data)
        .select()
        .single();

    return CommentModel.fromJson(response);
  }

  @override
  Future<void> updateComment(CommentModel comment) async {
    // Only send fields that are allowed to change to avoid UUID format errors
    // with placeholder data (like empty strings for cardId/authorId)
    await _client
        .from('comments')
        .update({
          'content': comment.content,
          'updated_at': comment.updatedAt?.toIso8601String(),
          'mentioned_user_ids': comment.mentionedUserIds,
        })
        .eq('id', comment.id);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }
}
