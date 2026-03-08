import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../comment/domain/entities/comment.dart';
import '../../domain/entities/card_item.dart';
import '../../domain/usecases/get_cards_usecase.dart';
import 'card_usecase_provider.dart';

class CardNotifier extends FamilyAsyncNotifier<List<CardItem>, String> {

  late final GetCardsUseCase getCardsUseCase;

  @override
  Future<List<CardItem>> build(String columnId) async {

    getCardsUseCase = ref.read(getCardsUseCaseProvider);

    final result = await getCardsUseCase(columnId);

    return result.fold(
          (failure) => throw failure,
          (cards) => cards,
    );
  }

  Future<void> refreshColumnCards() async {

    state = const AsyncLoading<List<CardItem>>()
        .copyWithPrevious(state);

    final result = await getCardsUseCase(arg);

    result.fold(
          (failure) => state = AsyncError(failure, StackTrace.current),
          (cards) => state = AsyncData(cards),
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

    final createCard = ref.read(createCardUseCaseProvider);

    await createCard(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
      comments: comments,
    );

    await refreshColumnCards();
  }
}