import 'package:collaborative_knowledge_board/features/comment/data/models/comment_model.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/card_item_model.dart';

class CardRemoteDataSource {
  final DioClient dioClient;

  CardRemoteDataSource(this.dioClient);

  Future<List<CardItemModel>> getCards(String columnId) async {
    final response =
    await dioClient.get(ApiEndpoints.cardsByColumn(columnId));

    final List data = response.data;

    return data.map((e) => CardItemModel.fromJson(e)).toList();
  }

  Future<CardItemModel> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime? createdAt,
    required List<CommentModel> comments,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.cardsByColumn(columnId),
      data: {
        'id': id,
        'columnId': columnId,
        'title': title,
        'description': description,
        'position': position,
        'created_by': createdBy,
        'created_at': createdAt,
        'comments': comments,
      },
    );

    return CardItemModel.fromJson(response.data);
  }

  Future<CardItemModel> updateCard(CardItemModel card) async {
    final response = await dioClient.put(
      ApiEndpoints.cardById(card.id),
      data: {
        'title': card.title,
        'description': card.description,
        'position': card.position,
        'created_by': card.createdBy,
        'created_at': card.createdAt,
        'comments': card.comments,
      },
    );

    return CardItemModel.fromJson(response.data);
  }

  Future<void> deleteCard(String cardId) async {
    await dioClient.delete(ApiEndpoints.cardById(cardId));
  }
}