import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_item.dart';
import 'card_usecase_provider.dart';

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
}