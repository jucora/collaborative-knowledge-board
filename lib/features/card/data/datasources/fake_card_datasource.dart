import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import '../../../../core/fake_data/fake_database.dart';
import '../models/card_item_model.dart';
import 'card_remote_datasource.dart';

/// Fake Datasource that simulates a backend by managing cards in memory.
class FakeCardDatasource implements CardRemoteDataSource {
  final FakeDatabase database;

  FakeCardDatasource(this.database);

  @override
  Future<List<CardItemModel>> getCards(String columnId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final cards = database.cards
        .where((c) => c.columnId == columnId)
        .toList();

    cards.sort((a, b) => a.position.compareTo(b.position));

    // Ensure we return models, not entities
    return cards.map((e) => CardItemModel.fromEntity(e)).toList();
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
    await Future.delayed(const Duration(milliseconds: 300));
    final newCard = CardItem(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
    );
    database.cards.add(newCard);
    return CardItemModel.fromEntity(newCard);
  }

  @override
  Future<CardItemModel> updateCard(CardItemModel card) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = database.cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      // Store it as a Model (which is a CardItem) in the fake DB
      database.cards[index] = card;
      return card;
    }
    throw Exception('Card not found');
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    database.cards.removeWhere((c) => c.id == cardId);
  }
}
