import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/card_item.dart';
import '../repositories/card_repository.dart';

class GetCardsUseCase {
  final CardRepository repository;

  GetCardsUseCase(this.repository);

  Future<Either<Failure, List<CardItem>>> call(String columnId) {
    return repository.getCards(columnId);
  }
}