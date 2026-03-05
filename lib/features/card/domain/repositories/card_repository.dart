import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../comment/domain/entities/comment.dart';
import '../entities/card_item.dart';

abstract class CardRepository {
  Future<Either<Failure, List<CardItem>>> getCards(String columnId);

  Future<Either<Failure, CardItem>> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime? createdAt,
    required List<Comment> comments,
  });

  Future<Either<Failure, CardItem>> updateCard(CardItem card);

  Future<Either<Failure, void>> deleteCard(String cardId);
}