import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/card_repository.dart';

class DeleteCardUseCase {
  final CardRepository repository;

  DeleteCardUseCase(this.repository);

  Future<Either<Failure, void>> call(String cardId) {
    return repository.deleteCard(cardId);
  }
}