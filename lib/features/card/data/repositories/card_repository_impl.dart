import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/providers/config_provider.dart';
import '../../../../core/services/real_time_service.dart';
import '../../domain/entities/card_item.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_remote_datasource.dart';
import '../models/card_item_model.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource remoteDataSource;
  final SupabaseClient _supabase = Supabase.instance.client;

  CardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CardItem>>> getCards(String columnId) async {
    try {
      final models = await remoteDataSource.getCards(columnId);
      return Right(models);
    } catch (e) {
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
    required DateTime createdAt,
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
      return Right(model);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

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

      final model = await remoteDataSource.updateCard(
        CardItemModel.fromEntity(card),
      );
      return Right(model);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(String cardId) async {
    try {
      await remoteDataSource.deleteCard(cardId);
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Stream<RealTimeEvent> watchCards() {
    if (useFakeData) return const Stream.empty();

    // SUPABASE REAL-TIME
    // Using .stream() is the most straightforward way to listen to table changes in Flutter.
    return _supabase
        .from('cards')
        .stream(primaryKey: ['id'])
        .map((_) => RealTimeEvent(RealTimeEventType.cardUpdated, null));
  }
}
