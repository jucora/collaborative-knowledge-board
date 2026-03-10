import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import '../../../../core/fake_data/fake_database.dart';

/// Fake Datasource that simulates a backend by managing cards in memory.
/// This class is the "Source of Truth" for the application's card data during development.
class FakeCardDatasource {

  final FakeDatabase database;

  FakeCardDatasource(this.database);

  /// Retrieves all cards belonging to a specific column.
  /// 
  /// INTER-COLUMN DRAG: When a card's columnId is updated, this filter ensures 
  /// it appears in the new column and disappears from the old one.
  /// 
  /// INTRA-COLUMN REORDER: Before returning, cards are sorted by their [position] 
  /// property to maintain the user's custom order.
  Future<List<CardItem>> getCardsByColumn(String columnId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final cards = database.cards
        .where((c) => c.columnId == columnId)
        .toList();

    // Sorting is crucial for ReorderableListView to display cards in the correct sequence.
    cards.sort((a, b) => a.position.compareTo(b.position));

    return cards;
  }

  /// Adds a new card to the database.
  Future<void> createCard(CardItem card) async {
    database.cards.add(card);
  }
  
  /// Updates an existing card's properties in the in-memory list.
  /// 
  /// This method handles two critical scenarios:
  /// 1. Movement between columns: by updating the [columnId].
  /// 2. Reordering within a column: by updating the [position] index.
  Future<CardItem> updateCard(CardItem card) async {
    final index = database.cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      // Replaces the old card state with the new one.
      database.cards[index] = card;
      return card;
    }
    throw Exception('Card not found');
  }
}