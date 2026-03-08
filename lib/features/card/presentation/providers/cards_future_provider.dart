import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'card_usecase_provider.dart';

final cardsProvider =
FutureProvider.family<List<CardItem>, String>((ref, columnId) async {

  final useCase = ref.watch(getCardsUseCaseProvider);

  final result = await useCase(columnId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (cards) => cards,
  );
});