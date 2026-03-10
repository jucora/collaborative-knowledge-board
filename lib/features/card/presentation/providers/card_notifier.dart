import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_item.dart';
import 'card_usecase_provider.dart';

/// Notifier that manages the state of a list of cards for a specific column.
/// Inherits from [FamilyAsyncNotifier] to handle different columns by their ID.
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

  /// Creates a new card and updates the local state.
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

        state = state.whenData((cards) => [...cards, newCard]);
      },
    );
  }

  /// Updates a card's information.
  /// This is crucial for Drag & Drop: if the card moved to a different column,
  /// it removes the card from the current column's state.
  Future<void> updateCard(CardItem card) async {
    final useCase = ref.read(updateCardUseCaseProvider);
    final result = await useCase(card);

    result.fold(
          (failure) => throw Exception(failure.message),
          (updatedCard) {
        // If the card is still in this column (e.g., just position changed), update local list.
        if (updatedCard.columnId == columnId) {
          state = state.whenData((cards) {
            return cards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList();
          });
        } else {
          // If the card moved to another column, remove it from this notifier's state.
          state = state.whenData((cards) {
            return cards.where((c) => c.id != updatedCard.id).toList();
          });
        }
      },
    );
  }

  /// Adds a card to the local state without triggering a backend call.
  /// Used for immediate UI feedback during Drag & Drop (Optimistic UI).
  void addCardLocally(CardItem card) {
    state = state.whenData((cards) {
      if (cards.any((c) => c.id == card.id)) return cards;
      return [...cards, card];
    });
  }
}