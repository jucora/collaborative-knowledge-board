import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/card_item.dart';
import '../repositories/card_repository.dart';

class CreateCardUseCase {
  final CardRepository repository;

  CreateCardUseCase(this.repository);

  Future<Either<Failure, CardItem>> call({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  }) {
    return repository.createCard(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}