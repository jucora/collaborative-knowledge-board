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
    
    // 1. Remove temp ID to let DB generate UUID
    data.remove('id');
    
    // 2. Validate parentId format. 
    // If it's a numeric string (temp ID from Flutter), it will fail in Postgres as UUID.
    // We only send it if it's a valid UUID.
    final parentId = data['parent_id'] as String?;
    if (parentId != null && RegExp(r'^\d+$').hasMatch(parentId)) {
      data.remove('parent_id');
    }
    
    final response = await _client
        .from('comments')
        .insert(data)
        .select()
        .single();

    return CommentModel.fromJson(response);
  }

  @override
  Future<void> updateComment(CommentModel comment) async {
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
