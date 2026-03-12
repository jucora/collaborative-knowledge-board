import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/card_item.dart';
import 'card_repository_provider.dart';
import 'card_usecase_provider.dart';

/// Notifier responsible for managing the state of cards within a specific column.
class CardNotifier extends FamilyAsyncNotifier<List<CardItem>, String> {

  late String columnId;
  StreamSubscription? _subscription;

  // Track preview state for "Ghost" effect during inter-column drag
  String? _previewCardId;
  int? _previewIndex;

  @override
  Future<List<CardItem>> build(String arg) async {
    columnId = arg;
    
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

  /// Updates the list visual order during an active drag from another column.
  void updatePreview(CardItem draggedCard, double localY, double itemHeight) {
    state = state.whenData((cards) {
      // 1. Remove the card if it already exists in this column to calculate correct bounds
      final List<CardItem> listWithoutDragged = cards.where((c) => c.id != draggedCard.id).toList();
      
      // 2. Calculate target index based on vertical position, clamped to the NEW list length
      int newIndex = (localY / itemHeight).floor().clamp(0, listWithoutDragged.length);
      
      // Optimization: avoid redundant state updates
      if (_previewIndex == newIndex && _previewCardId == draggedCard.id) return cards;

      _previewIndex = newIndex;
      _previewCardId = draggedCard.id;

      // 3. Insert the "Ghost" card at the safe calculated position
      listWithoutDragged.insert(newIndex, draggedCard);
      
      return listWithoutDragged;
    });
  }

  /// Cleans up the preview state when the drag leaves the column or ends.
  void removePreview(String cardId) {
    if (_previewCardId == cardId) {
      _previewCardId = null;
      _previewIndex = null;
      ref.invalidateSelf(); 
    }
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
      final belongsToThisColumn = updatedCard.columnId == columnId;
      final existsLocally = cards.any((c) => c.id == updatedCard.id);
      
      if (belongsToThisColumn) {
        if (existsLocally) {
          return cards.map((c) => c.id == updatedCard.id ? updatedCard : c).toList()
            ..sort((a, b) => a.position.compareTo(b.position));
        } else {
          return [...cards, updatedCard]
            ..sort((a, b) => a.position.compareTo(b.position));
        }
      } else {
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

  /// Creates a card with Offline Support.
  Future<void> createCard({
    required String id,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  }) async {
    final isOnline = ref.read(realTimeServiceProvider).isConnected;
    final syncService = ref.read(syncServiceProvider);

    final card = CardItem(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
    );

    addCardLocally(card);

    if (isOnline) {
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
    } else {
      syncService.addAction('createCard', card);
    }
  }

  /// Updates a card with Offline Support.
  Future<void> updateCard(CardItem card) async {
    final isOnline = ref.read(realTimeServiceProvider).isConnected;
    final syncService = ref.read(syncServiceProvider);

    _updateCardLocally(card);

    if (isOnline) {
      final useCase = ref.read(updateCardUseCaseProvider);
      await useCase(card);
    } else {
      syncService.addAction('updateCard', card);
    }
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