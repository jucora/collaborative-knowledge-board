import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:collaborative_knowledge_board/features/card/data/datasources/fake_card_datasource.dart';
import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import 'package:collaborative_knowledge_board/features/card/domain/repositories/card_repository.dart';
import 'package:collaborative_knowledge_board/features/comment/domain/entities/comment.dart';
import 'package:dartz/dartz.dart';

class FakeCardRepositoryImpl extends CardRepository {

  FakeCardDatasource? datasource;

  FakeCardRepositoryImpl(FakeCardDatasource datasource){
    this.datasource = datasource;
  }

  @override
  Future<Either<Failure, CardItem>> createCard({
    required String id,
    required String columnId,
    required String title,
    required String description,
    required int position,
    required String createdBy,
    required DateTime? createdAt,
    required List<Comment> comments
  }) {
    // TODO: implement createCard
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteCard(String cardId) {
    // TODO: implement deleteCard
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<CardItem>>> getCards(String columnId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final cards = await datasource?.getCardsByColumn(columnId);

      return Right(cards!);
    } catch (e) {
      return Left(ServerFailure('Failed to load board cards'));
    }
  }

  @override
  Future<Either<Failure, CardItem>> updateCard(CardItem card) {
    // TODO: implement updateCard
    throw UnimplementedError();
  }
}