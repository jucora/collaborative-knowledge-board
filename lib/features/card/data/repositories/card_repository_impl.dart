import 'dart:async';
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
      final cardModel = CardItemModel(
        id: id,
        columnId: columnId,
        title: title,
        description: description,
        position: position,
        createdBy: createdBy,
        createdAt: createdAt,
      );

      final model = await remoteDataSource.updateCard(cardModel);
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

    final controller = StreamController<RealTimeEvent>();

    final channel = _supabase.channel('public:cards');
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'cards',
      callback: (payload) {
        final eventType = payload.eventType;
        
        RealTimeEventType type;
        Map<String, dynamic>? data;

        if (eventType == PostgresChangeEvent.insert) {
          type = RealTimeEventType.cardCreated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.update) {
          type = RealTimeEventType.cardUpdated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.delete) {
          type = RealTimeEventType.cardDeleted;
          data = payload.oldRecord;
        } else {
          return;
        }

        if (!controller.isClosed) {
          controller.add(RealTimeEvent(
            type,
            data != null ? CardItemModel.fromJson(data) : null,
          ));
        }
      },
    ).subscribe();

    // Properly clean up resources when the listener cancels the subscription
    controller.onCancel = () {
      _supabase.removeChannel(channel);
      controller.close();
    };

    return controller.stream;
  }
}
