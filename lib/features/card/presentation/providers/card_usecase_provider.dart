import 'package:collaborative_knowledge_board/features/card/domain/usecases/get_cards_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_card_usecase.dart';
import '../../domain/usecases/delete_card_usecase.dart';
import '../../domain/usecases/update_card_usecase.dart';
import 'card_repository_provider.dart';

final createCardUseCaseProvider =
    Provider<CreateCardUseCase>((ref) {
      final repository = ref.watch(cardRepositoryProvider);
      return CreateCardUseCase(repository);
    });

final deleteCardUseCaseProvider =
    Provider<DeleteCardUseCase>((ref) {
      final repository = ref.watch(cardRepositoryProvider);
      return DeleteCardUseCase(repository);
    });

final getCardsUseCaseProvider =
    Provider<GetCardsUseCase>((ref) {
      final repository = ref.watch(cardRepositoryProvider);
      return GetCardsUseCase(repository);
    });

final updateCardUseCaseProvider =
    Provider<UpdateCardUseCase>((ref) {
      final repository = ref.watch(cardRepositoryProvider);
      return UpdateCardUseCase(repository);
    });

