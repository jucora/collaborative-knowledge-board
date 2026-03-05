import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../comment/domain/entities/comment.dart';
import '../../domain/entities/card_item.dart';
import '../../domain/usecases/create_card_usecase.dart';
import '../../domain/usecases/delete_card_usecase.dart';
import '../../domain/usecases/get_cards_usecase.dart';
import '../../domain/usecases/update_card_usecase.dart';

class CardNotifier extends FamilyAsyncNotifier<List<CardItem>, String> {
  late final GetCardsUseCase _getCards;
  late final CreateCardUseCase _createCard;
  late final UpdateCardUseCase _updateCard;
  late final DeleteCardUseCase _deleteCard;

  @override
  Future<List<CardItem>> build(String columnId) async {
    final result = await _getCards(columnId);

    return result.fold(
          (failure) => throw failure,
          (cards) => cards,
    );
  }

  Future<void> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime? createdAt,
    required List<Comment> comments,

  }) async {
    final result = await _createCard(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
      comments: comments,
    );

    result.fold(
          (failure) => state = AsyncError(failure, StackTrace.current),
          (card) => state = AsyncData([...state.value!, card]),
    );
  }

  Future<void> deleteCard(String id) async {
    final result = await _deleteCard(id);

    result.fold(
          (failure) => state = AsyncError(failure, StackTrace.current),
          (_) => state =
          AsyncData(state.value!.where((c) => c.id != id).toList()),
    );
  }
}