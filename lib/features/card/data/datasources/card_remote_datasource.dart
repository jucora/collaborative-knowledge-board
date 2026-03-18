import '../models/card_item_model.dart';

abstract class CardRemoteDataSource {
  Future<List<CardItemModel>> getCards(String columnId);

  Future<CardItemModel> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  });

  Future<CardItemModel> updateCard(CardItemModel card);

  Future<void> deleteCard(String cardId);
}
