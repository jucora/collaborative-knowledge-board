import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_item.dart';
import 'card_usecase_provider.dart';

/// Notifier responsible for managing the state of cards within a specific column.
/// 
/// It uses the [FamilyAsyncNotifier] to maintain independent states for each column ID.
class CardNotifier extends FamilyAsyncNotifier<List<CardItem>, String> {

  late String columnId;

  @override
  Future<List<CardItem>> build(String arg) async {
    columnId = arg;
    final useCase = ref.read(getCardsUseCaseProvider);
    final result = await useCase(columnId);

    return result.fold(
          (failure) => throw Exception(failure.message),
          (cards) => cards,
    );
  }

  /// Creates a new card and adds it to the current column's state.
  Future<void> createCard({
    required String id,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  }) async {

    final useCase = ref.read(createCardUseCaseProvider);

    final result = await useCase(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
    );

    result.fold(
          (failure) => throw Exception(failure.message),
          (_) {
        final newCard = CardItem(
          id: id,
          columnId: columnId,
          title: title,
          description: description,
          position: position,
          createdBy: createdBy,
          createdAt: createdAt,
        );

        // Update the state with the new card added to the list.
        state = state.whenData((cards) => [...cards, newCard]);
      },
    );
  }

  /// Handles the logic for moving a card to a different column or updating its data.
  /// 
  /// INTER-COLUMN DRAG: 
  /// If the [updatedCard.columnId] no longer matches this notifier's [columnId], 
  /// the card is removed from the local state.
  Future<void> updateCard(CardItem card) async {
    final useCase = ref.read(updateCardUseCaseProvider);
    final result = await useCase(card);

    result.fold(
          (failure) => throw Exception(failure.message),
          (updatedCard) {
        if (updatedCard.columnId == columnId) {
          // If the card remains in this column, update its properties in the list.
          state = state.whenData((cards) {
            return cards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList();
          });
        } else {
          // If the card moved away, remove it from this specific column's state.
          state = state.whenData((cards) {
            return cards.where((c) => c.id != updatedCard.id).toList();
          });
        }
      },
    );
  }

  /// Adds a card to the state immediately without waiting for a backend response.
  /// 
  /// OPTIMISTIC UI: This is called by the TARGET column during an inter-column drag 
  /// to make the transition feel instantaneous to the user.
  void addCardLocally(CardItem card) {
    state = state.whenData((cards) {
      if (cards.any((c) => c.id == card.id)) return cards;
      return [...cards, card];
    });
  }

  /// Handles reordering cards within the SAME column.
  /// 
  /// INTRA-COLUMN DRAG:
  /// 1. Rearranges the local list for immediate visual feedback.
  /// 2. Iterates through the list to update each card's [position] index in the database.
  Future<void> reorderCards(int oldIndex, int newIndex) async {
    final cards = state.value;
    if (cards == null) return;

    // Flutter's ReorderableListView adjustment for moving items down.
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // 1. Rearrange the list locally.
    final List<CardItem> updatedList = List.from(cards);
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    // 2. Set the state immediately so the animation is smooth.
    state = AsyncData(updatedList);

    // 3. Persist the new order by updating the position of each card.
    // In a production app, you might use a batch update or a specific reorder endpoint.
    for (int i = 0; i < updatedList.length; i++) {
      final card = updatedList[i].copyWith(position: i);
      await updateCard(card);
    }
  }
}