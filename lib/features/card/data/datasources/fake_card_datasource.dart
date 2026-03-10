import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import '../../../../core/fake_data/fake_database.dart';

/// Fake Datasource to handle card operations in memory.
class FakeCardDatasource {

  final FakeDatabase database;

  FakeCardDatasource(this.database);

  /// Fetches cards filtered by column ID.
  Future<List<CardItem>> getCardsByColumn(String columnId) async {

    await Future.delayed(const Duration(milliseconds: 200));

    return database.cards
        .where((c) => c.columnId == columnId)
        .toList();
  }

  /// Adds a new card to the in-memory database.
  Future<void> createCard(CardItem card) async {
    database.cards.add(card);
  }
  
  /// Updates an existing card. 
  /// Essential for Drag & Drop as it changes the columnId of a card.
  Future<CardItem> updateCard(CardItem card) async {
    final index = database.cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      // Updates the card in the list, effectively changing its column or properties.
      database.cards[index] = card;
      return card;
    }
    throw Exception('Card not found');
  }
}