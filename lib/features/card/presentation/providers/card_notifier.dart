import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/card_item.dart';
import '../../data/models/card_item_model.dart';
import 'card_repository_provider.dart';
import 'card_usecase_provider.dart';

/// Notifier responsible for managing the state of cards within a specific column.
class CardNotifier extends FamilyAsyncNotifier<List<CardItem>, String> {

  late String columnId;
  StreamSubscription? _subscription;

  String? _previewCardId;
  int? _previewIndex;
  
  // Track IDs of cards updated locally to avoid UI jumps during sync
  final Set<String> _locallyUpdatedIds = {};

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
          (cards) => cards.map((e) => CardItemModel.fromEntity(e)).toList(),
    );
  }

  void updatePreview(CardItem draggedCard, double localY, double itemHeight) {
    state = state.whenData((cards) {
      final List<CardItem> listWithoutDragged = cards.where((c) => c.id != draggedCard.id).toList();
      int newIndex = (localY / itemHeight).round().clamp(0, listWithoutDragged.length);
      
      if (_previewIndex == newIndex && _previewCardId == draggedCard.id) return cards;

      _previewIndex = newIndex;
      _previewCardId = draggedCard.id;

      final cardToInsert = CardItemModel.fromEntity(draggedCard);
      listWithoutDragged.insert(newIndex, cardToInsert);
      
      return listWithoutDragged;
    });
  }

  void removePreview(String cardId) {
    if (_previewCardId == cardId) {
      _previewCardId = null;
      _previewIndex = null;
    }
  }

  void _handleRealTimeEvent(RealTimeEvent event) {
    if (event.data == null) {
      if (_locallyUpdatedIds.isEmpty) {
        ref.invalidateSelf();
      }
      return;
    }

    final card = event.data as CardItem;
    if (_locallyUpdatedIds.contains(card.id)) return;

    final syncService = ref.read(syncServiceProvider);
    final isPending = syncService.pendingActions.any(
      (a) => a.data is CardItem && (a.data as CardItem).id == card.id
    );
    
    if (isPending) return;

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
      
      final cardModel = CardItemModel.fromEntity(updatedCard);

      if (belongsToThisColumn) {
        if (existsLocally) {
          return cards.map((c) => c.id == updatedCard.id ? cardModel : c).toList()
            ..sort((a, b) => a.position.compareTo(b.position));
        } else {
          // If it doesn't exist by ID, try to find an optimistic match to replace it
          return _addOrMergeCard(cards, cardModel);
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

    final card = CardItemModel(
      id: id, // Numeric temp ID
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
        (failure) => _removeCardLocally(id),
        (realCard) {
          // Immediately replace the temp ID with the real one to be ready for real-time events
          state = state.whenData((cards) {
            final List<CardItem> newList = cards.map((c) => c.id == id ? CardItemModel.fromEntity(realCard) : c).toList();
            return newList;
          });
        }
      );
    } else {
      syncService.addAction('createCard', card);
    }
  }

  Future<void> updateCard(CardItem card) async {
    final isOnline = ref.read(realTimeServiceProvider).isConnected;
    final syncService = ref.read(syncServiceProvider);

    _locallyUpdatedIds.add(card.id);
    _updateCardLocally(card);

    if (isOnline) {
      final useCase = ref.read(updateCardUseCaseProvider);
      // Fixed: Passing the CardItem object directly as expected by UpdateCardUseCase.call(CardItem card)
      await useCase(card);
    } else {
      syncService.addAction('updateCard', CardItemModel.fromEntity(card));
    }
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _locallyUpdatedIds.remove(card.id);
    });
  }

  void addCardLocally(CardItem card) {
    state = state.whenData((cards) {
      if (cards.any((c) => c.id == card.id)) return cards;
      return _addOrMergeCard(cards, CardItemModel.fromEntity(card));
    });
  }

  /// Helper to add a card or merge it if an optimistic (temp ID) version exists
  List<CardItem> _addOrMergeCard(List<CardItem> cards, CardItemModel newCard) {
    // Look for a card with same title/pos that has a temporary numeric ID
    final optimisticIndex = cards.indexWhere((c) => 
      c.title == newCard.title && 
      c.position == newCard.position && 
      RegExp(r'^\d+$').hasMatch(c.id) // Check if ID is numeric (temp timestamp)
    );

    if (optimisticIndex != -1) {
      final List<CardItem> newList = List.from(cards);
      newList[optimisticIndex] = newCard; // Replace temp with real
      return newList;
    }

    final List<CardItem> newList = [...cards, newCard];
    newList.sort((a, b) => a.position.compareTo(b.position));
    return newList;
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
