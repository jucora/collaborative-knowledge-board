import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/board_model.dart';
import 'board_remote_datasource.dart';

class SupabaseBoardDataSourceImpl implements BoardRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;


  @override
  Future<List<BoardModel>> getBoards() async {
    // Supabase will automatically filter thanks to RLS policies
    // returning only the dashboards where the user has access.
    final response = await _client
        .from('boards')
        .select('*, columns:columns(*, cards:cards(*)), members:board_members(*)');

    return (response as List)
        .map((json) => BoardModel.fromJson(json))
        .toList();
  }

  @override
  Future<BoardModel> createBoard({
    required String title,
    required String description,
  }) async {
    final userId = _client.auth.currentUser?.id;

    final response = await _client
        .from('boards')
        .insert({
      'title': title,
      'description': description,
      'owner_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    })
        .select('*, columns:columns(*), members:board_members(*)')
        .single();

    return BoardModel.fromJson(response);
  }

  @override
  Future<void> deleteBoard(String id) async {
    await _client.from('boards').delete().eq('id', id);
  }
}
