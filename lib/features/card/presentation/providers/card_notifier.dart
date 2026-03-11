import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../domain/entities/card_item.dart';
import 'card_repository_provider.dart';
import 'card_usecase_provider.dart';

/// Notifier responsible for managing the state of cards within a specific column.
class CardNotifier extends FamilyAsyncNotifier<List<CardItem>, String> {

  late String columnId;
  StreamSubscription? _subscription;

  @override
  Future<List<CardItem>> build(String arg) async {
    columnId = arg;
    
    // Subscribe to real-time events from the repository
    final repository = ref.read(cardRepositoryProvider);
    _subscription?.cancel();
    _subscription = repository.watchCards().listen(_handleRealTimeEvent);

    final useCase = ref.read(getCardsUseCaseProvider);
    final result = await useCase(columnId);

    return result.fold(
          (failure) => throw Exception(failure.message),
          (cards) => cards,
    );
  }

  void _handleRealTimeEvent(RealTimeEvent event) {
    if (event.data == null) {
      ref.invalidateSelf();
      return;
    }

    final card = event.data as CardItem;

    switch (event.type) {
      case RealTimeEventType.cardCreated:
        if (card.columnId == columnId) {
          addCardLocally(card);
        }
        break;
      case RealTimeEventType.cardUpdated:
        _updateCardLocally(card);
        break;
      case RealTimeEventType.cardDeleted:
        _removeCardLocally(card.id);
        break;
      default:
        break;
    }
  }

  void _updateCardLocally(CardItem updatedCard) {
    state = state.whenData((cards) {
      // Check if the card belongs to THIS column
      final belongsToThisColumn = updatedCard.columnId == columnId;
      // Check if the card currently exists in our local list
      final existsLocally = cards.any((c) => c.id == updatedCard.id);
      
      if (belongsToThisColumn) {
        if (existsLocally) {
          // UPDATE: Replace existing card with new data
          return cards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList()
            ..sort((a, b) => a.position.compareTo(b.position));
        } else {
          // MOVE IN: Add card that just arrived from another column
          return [...cards, updatedCard]
            ..sort((a, b) => a.position.compareTo(b.position));
        }
      } else {
        // MOVE OUT: If the card no longer belongs here but we have it, REMOVE IT
        if (existsLocally) {
          return cards.where((c) => c.id != updatedCard.id).toList();
        }
      }
      return cards;
    });
  }

  void _removeCardLocally(String cardId) {
    state = state.whenData((cards) {
      return cards.where((c) => c.id != cardId).toList();
    });
  }

  Future<void> createCard({
    required String id,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  }) async {
    final useCase = ref.read(createCardUseCaseProvider);
    await useCase(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  Future<void> updateCard(CardItem card) async {
    final useCase = ref.read(updateCardUseCaseProvider);
    await useCase(card);
    // State update will be handled by the real-time stream subscription
  }

  void addCardLocally(CardItem card) {
    state = state.whenData((cards) {
      if (cards.any((c) => c.id == card.id)) return cards;
      final newList = [...cards, card];
      newList.sort((a, b) => a.position.compareTo(b.position));
      return newList;
    });
  }

  Future<void> reorderCards(int oldIndex, int newIndex) async {
    final cards = state.value;
    if (cards == null) return;

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final List<CardItem> updatedList = List.from(cards);
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    state = AsyncData(updatedList);

    for (int i = 0; i < updatedList.length; i++) {
      final card = updatedList[i].copyWith(position: i);
      await updateCard(card);
    }
  }
}