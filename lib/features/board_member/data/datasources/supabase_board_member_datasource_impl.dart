import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/board_member_model.dart';
import 'board_member_remote_datasource.dart';

class SupabaseBoardMemberDataSourceImpl implements BoardMemberRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<BoardMemberModel>> getBoardMembers(String boardId) async {
    final response = await _client
        .from('board_members')
        .select()
        .eq('board_id', boardId);

    return (response as List)
        .map((json) => BoardMemberModel.fromJson(json))
        .toList();
  }

  @override
  Future<BoardMemberModel> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
    required DateTime joinedAt,
  }) async {
    final response = await _client
        .from('board_members')
        .insert({
          'board_id': boardId,
          'user_id': userId,
          'role': role,
          'joined_at': joinedAt.toIso8601String(),
        })
        .select()
        .single();

    return BoardMemberModel.fromJson(response);
  }

  @override
  Future<void> removeBoardMember({
    required String boardId,
    required String userId,
  }) async {
    await _client
        .from('board_members')
        .delete()
        .eq('board_id', boardId)
        .eq('user_id', userId);
  }
}
