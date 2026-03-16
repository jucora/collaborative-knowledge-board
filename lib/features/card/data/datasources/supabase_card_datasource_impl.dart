import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/card_item_model.dart';
import 'card_remote_datasource.dart';

class SupabaseCardDataSourceImpl implements CardRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<CardItemModel>> getCards(String columnId) async {
    final response = await _client
        .from('cards')
        .select()
        .eq('columnId', columnId)
        .order('position', ascending: true);

    return (response as List)
        .map((json) => CardItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<CardItemModel> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  }) async {
    final response = await _client
        .from('cards')
        .insert({
          'id': id,
          'columnId': columnId,
          'title': title,
          'description': description,
          'position': position,
          'createdBy': createdBy,
          'createdAt': createdAt.toIso8601String(),
        })
        .select()
        .single();

    return CardItemModel.fromJson(response);
  }

  @override
  Future<CardItemModel> updateCard(CardItemModel card) async {
    final response = await _client
        .from('cards')
        .update(card.toJson())
        .eq('id', card.id)
        .select()
        .single();

    return CardItemModel.fromJson(response);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await _client.from('cards').delete().eq('id', cardId);
  }
}
