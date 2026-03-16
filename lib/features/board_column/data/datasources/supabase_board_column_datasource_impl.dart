import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/board_column_model.dart';
import 'board_column_remote_datasource.dart';

class SupabaseBoardColumnDataSourceImpl implements BoardColumnRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<BoardColumnModel>> getBoardColumns(String boardId) async {
    final response = await _client
        .from('columns')
        .select('*, cards:cards(*)')
        .eq('boardId', boardId)
        .order('position', ascending: true);

    return (response as List)
        .map((json) => BoardColumnModel.fromJson(json))
        .toList();
  }

  @override
  Future<BoardColumnModel> createBoardColumn({
    required String boardId,
    required String title,
    required int position,
  }) async {
    final response = await _client
        .from('columns')
        .insert({
          'boardId': boardId,
          'title': title,
          'position': position,
        })
        .select('*, cards:cards(*)')
        .single();

    return BoardColumnModel.fromJson(response);
  }

  @override
  Future<void> updateBoardColumn(BoardColumnModel column) async {
    await _client
        .from('columns')
        .update(column.toJson())
        .eq('id', column.id);
  }

  @override
  Future<void> deleteBoardColumn(String id) async {
    await _client.from('columns').delete().eq('id', id);
  }
}
