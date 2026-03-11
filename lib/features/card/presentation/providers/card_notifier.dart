import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../domain/entities/card_item.dart';
import 'card_repository_provider.dart';
import 'card_usecase_provider.dart';

/// Notifier responsible for managing the state of cards within a specific column.
/// 
/// It uses the [FamilyAsyncNotifier] to maintain independent states for each column ID.
class CardNotifier extends FamilyAsyncNotifier<List<CardItem>, String> {

  late String columnId;
  StreamSubscription? _subscription;

  @override
  Future<List<CardItem>> build(String arg) async {
    columnId = arg;
    
    // START: Real-Time Implementation
    // Subscribing to card updates from the repository.
    final repository = ref.read(cardRepositoryProvider);
    _subscription?.cancel(); // Cancel any existing subscription before creating a new one.
    _subscription = repository.watchCards().listen(_handleRealTimeEvent);
    // END: Real-Time Implementation

    final useCase = ref.read(getCardsUseCaseProvider);
    final result = await useCase(columnId);

    return result.fold(
          (failure) => throw Exception(failure.message),
          (cards) => cards,
    );
  }

  /// Processes incoming real-time events and updates the UI state accordingly.
  void _handleRealTimeEvent(RealTimeEvent event) {
    if (event.data == null) {
      // HANDLE CONNECTION LOSS/RECOVERY:
      // If data is null, it means we regained connection or need a full sync.
      // We invalidate the provider to trigger a full re-fetch from the source.
      ref.invalidateSelf();
      return;
    }

    final card = event.data as CardItem;

    switch (event.type) {
      case RealTimeEventType.cardCreated:
        // Only add if the new card belongs to this specific column.
        if (card.columnId == columnId) {
          addCardLocally(card);
        }
        break;
      case RealTimeEventType.cardUpdated:
        // Handles updates, including when a card moves IN or OUT of this column.
        _updateCardLocally(card);
        break;
      case RealTimeEventType.cardDeleted:
        _removeCardLocally(card.id);
        break;
      default:
        break;
    }
  }

  /// Updates the local list of cards when a card is modified or moved between columns.
  void _updateCardLocally(CardItem updatedCard) {
    state = state.whenData((cards) {
      final exists = cards.any((c) => c.id == updatedCard.id);
      
      if (updatedCard.columnId == columnId) {
        if (exists) {
          // Card updated within the same column: update its data and maintain sort order.
          return cards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList()
            ..sort((a, b) => a.position.compareTo(b.position));
        } else {
          // INTER-COLUMN MOVE (TARGET): Card moved from another column into this one.
          return [...cards, updatedCard]
            ..sort((a, b) => a.position.compareTo(b.position));
        }
      } else {
        // INTER-COLUMN MOVE (SOURCE): Card moved away from this column.
        if (exists) {
          return cards.where((c) => c.id != updatedCard.id).toList();
        }
      }
      return cards;
    });
  }

  /// Removes a card from the current state.
  void _removeCardLocally(String cardId) {
    state = state.whenData((cards) {
      return cards.where((c) => c.id != cardId).toList();
    });
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
        // NOTE: We don't manually add the card to the state here because 
        // the Repository will emit a 'cardCreated' event via the RealTimeService, 
        // and _handleRealTimeEvent will take care of the UI update.
        // This ensures consistency across all devices.
      },
    );
  }

  /// Handles the logic for moving a card to a different column or updating its data.
  Future<void> updateCard(CardItem card) async {
    final useCase = ref.read(updateCardUseCaseProvider);
    final result = await useCase(card);

    result.fold(
      (failure) => throw Exception(failure.message),
      (updatedCard) {
        // UI is updated reactively via the Real-Time stream.
      },
    );
  }

  /// Adds a card to the state immediately without waiting for a backend response.
  void addCardLocally(CardItem card) {
    state = state.whenData((cards) {
      // Prevent duplicate additions if the stream and local call happen simultaneously.
      if (cards.any((c) => c.id == card.id)) return cards;
      final newList = [...cards, card];
      newList.sort((a, b) => a.position.compareTo(b.position));
      return newList;
    });
  }

  /// Handles reordering cards within the SAME column.
  Future<void> reorderCards(int oldIndex, int newIndex) async {
    final cards = state.value;
    if (cards == null) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final List<CardItem> updatedList = List.from(cards);
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    // OPTIMISTIC UI: Update state immediately for a smooth animation.
    state = AsyncData(updatedList);

    // Persist changes by updating positions in the database.
    for (int i = 0; i < updatedList.length; i++) {
      final card = updatedList[i].copyWith(position: i);
      await updateCard(card);
    }
  }
}