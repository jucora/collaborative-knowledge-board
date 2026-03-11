import 'package:collaborative_knowledge_board/core/services/real_time_service.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/card_item.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_remote_datasource.dart';

/// Production implementation of CardRepository.
class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource remoteDataSource;

  CardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CardItem>>> getCards(String columnId) async {
    try {
      final models = await remoteDataSource.getCards(columnId);

      final entities = models
          .map((model) => model.toEntity())
          .toList();

      return Right(entities);
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
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
  }) async {
    try {

      final model = await remoteDataSource.createCard(
        id: id,
        columnId: columnId,
        title: title,
        description: description,
        position: position,
        createdBy: createdBy,
        createdAt: createdAt,
      );

      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(String cardId) async {
    try {
      await remoteDataSource.deleteCard(cardId);

      return const Right(null);
    } on Exception catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, CardItem>> updateCard({required String id, required String columnId, required String title, required String description, required int position, required String createdBy, required DateTime createdAt}) {
    // TODO: implement updateCard
    throw UnimplementedError();
  }

  @override
  Stream<RealTimeEvent> watchCards() {
    // In a real production environment, this would connect to a WebSocket (e.g., Pusher, Socket.io, or Firebase).
    // For now, it returns an empty stream as the production backend is not yet fully implemented with real-time.
    return const Stream.empty();
  }
}