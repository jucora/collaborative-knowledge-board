import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/card_item.dart';
import '../repositories/card_repository.dart';

class UpdateCardUseCase {
  final CardRepository repository;

  UpdateCardUseCase(this.repository);

  Future<Either<Failure, CardItem>> call(CardItem card) {
    return repository.updateCard(
      id: card.id,
      columnId: card.columnId,
      title: card.title,
      description: card.description,
      position: card.position,
      createdBy: card.createdBy,
      createdAt: card.createdAt,
    );
  }
}