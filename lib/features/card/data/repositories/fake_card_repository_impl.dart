import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:collaborative_knowledge_board/features/card/data/datasources/fake_card_datasource.dart';
import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:collaborative_knowledge_board/features/card/domain/repositories/card_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../comment/data/datasources/fake_comment_datasource.dart';

/// Repository implementation using a fake datasource for development and testing.
class FakeCardRepositoryImpl extends CardRepository {

  FakeCardDatasource cardDatasource;
  FakeCommentDataSource commentDatasource;

  FakeCardRepositoryImpl(
      this.cardDatasource,
      this.commentDatasource,
      );

  @override
  Future<Either<Failure, CardItem>> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  }) async {

    try {
      final card = CardItem(
        id: id,
        columnId: columnId,
        title: title,
        description: description,
        position: position,
        createdBy: createdBy,
        createdAt: createdAt,
      );

      await cardDatasource.createCard(card);
      return Right(card);
    } catch (e) {
      return const Left(ServerFailure('Failed to create card'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(String cardId) {
    throw UnimplementedError();
  }

  /// Retrieves cards for a specific column.
  @override
  Future<Either<Failure, List<CardItem>>> getCards(String columnId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final cards = await cardDatasource.getCardsByColumn(columnId);
      return Right(cards);
    } catch (e) {
      return const Left(ServerFailure('Failed to load board cards'));
    }
  }

  /// Updates card details in the fake database.
  /// Used during Drag & Drop to persist column changes.
  @override
  Future<Either<Failure, CardItem>> updateCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime createdAt,
  }) async {
    try {
      final card = CardItem(
        id: id,
        columnId: columnId,
        title: title,
        description: description,
        position: position,
        createdBy: createdBy,
        createdAt: createdAt,
      );

      final updatedCard = await cardDatasource.updateCard(card);
      return Right(updatedCard);
    } catch (e) {
      return const Left(ServerFailure('Failed to update card'));
    }
  }
}