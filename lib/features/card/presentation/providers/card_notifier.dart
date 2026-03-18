import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../comment/domain/entities/comment.dart';
import '../../../comment/presentation/providers/comment_notifier_provider.dart';
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
          (cards) {
            final List<CardItem> items = cards.map((e) => e).toList();
            items.sort((a, b) => a.position.compareTo(b.position));
            return items;
          }
    );
  }

  void updatePreview(CardItem draggedCard, double localY, double itemHeight) {
    state = state.whenData((cards) {
      final List<CardItem> listWithoutDragged = cards.where((c) => c.id != draggedCard.id).toList();
      int newIndex = (localY / itemHeight).round().clamp(0, listWithoutDragged.length);
      
      if (_previewIndex == newIndex && _previewCardId == draggedCard.id) return cards;

      _previewIndex = newIndex;
      _previewCardId = draggedCard.id;

      final cardToInsert = draggedCard.copyWith(columnId: columnId);
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

    if (event.type == RealTimeEventType.cardDeleted) {
      final String deletedId = (event.data is CardItem) ? (event.data as CardItem).id : event.data.toString();
      _removeCardLocally(deletedId);
      return;
    }

    if (event.data is! CardItem) return;

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
          return _addOrMergeCard(cards, updatedCard);
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
    List<Comment> initialComments = const [],
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

    // Save initial comments
    for (var comment in initialComments) {
      ref.read(commentNotifierProvider(id).notifier).createComment(
        id: comment.id,
        cardId: id,
        authorId: comment.authorId,
        content: comment.content,
        createdAt: comment.createdAt,
      );
    }

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
        (failure) {
          if (failure.code == '23503') {
             syncService.addAction('createCard', CardItemModel.fromEntity(card));
          } else {
             _removeCardLocally(id);
          }
        },
        (realCard) {
          state = state.whenData((cards) {
            return cards.map((c) => c.id == id ? realCard : c).toList();
          });
        }
      );
    } else {
      syncService.addAction('createCard', CardItemModel.fromEntity(card));
    }
  }

  Future<void> updateCard(CardItem card) async {
    final isOnline = ref.read(realTimeServiceProvider).isConnected;
    final syncService = ref.read(syncServiceProvider);

    _locallyUpdatedIds.add(card.id);
    _updateCardLocally(card);

    if (isOnline) {
      final useCase = ref.read(updateCardUseCaseProvider);
      final result = await useCase(card);
      
      result.fold(
        (failure) {
           syncService.addAction('updateCard', CardItemModel.fromEntity(card));
        },
        (_) => null,
      );
    } else {
      syncService.addAction('updateCard', CardItemModel.fromEntity(card));
    }
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      _locallyUpdatedIds.remove(card.id);
    });
  }

  Future<void> editCard({
    required String cardId,
    required String title,
    required String description,
  }) async {
    final currentCards = state.value;
    if (currentCards == null) return;

    final index = currentCards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;

    final updatedCard = currentCards[index].copyWith(
      title: title,
      description: description,
    );

    await updateCard(updatedCard);
  }

  Future<void> deleteCard(String cardId) async {
    final isOnline = ref.read(realTimeServiceProvider).isConnected;
    _removeCardLocally(cardId);

    if (isOnline) {
      final useCase = ref.read(deleteCardUseCaseProvider);
      final result = await useCase(cardId);
      
      result.fold(
        (failure) => ref.invalidateSelf(),
        (_) => null,
      );
    } else {
      ref.read(syncServiceProvider).addAction('deleteCard', cardId);
    }
  }

  void addCardLocally(CardItem card) {
    state = state.whenData((cards) {
      if (cards.any((c) => c.id == card.id)) return cards;
      return _addOrMergeCard(cards, card);
    });
  }

  List<CardItem> _addOrMergeCard(List<CardItem> cards, CardItem newCard) {
    final optimisticIndex = cards.indexWhere((c) => 
      c.title == newCard.title && 
      c.position == newCard.position && 
      RegExp(r'^\d+$').hasMatch(c.id)
    );

    if (optimisticIndex != -1) {
      final List<CardItem> newList = List.from(cards);
      newList[optimisticIndex] = newCard;
      return newList;
    }

    final List<CardItem> newList = [...cards, newCard];
    newList.sort((a, b) => a.position.compareTo(b.position));
    return newList;
  }
  
  void moveFromHere(String cardId) {
     _removeCardLocally(cardId);
  }
}
