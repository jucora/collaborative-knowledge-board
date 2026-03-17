import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/real_time_service.dart';
import '../datasources/fake_card_datasource.dart';
import '../../domain/entities/card_item.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_remote_datasource.dart';
import '../models/card_item_model.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource remoteDataSource; // Supabase
  final CardRemoteDataSource localCacheSource; // FakeDB (Cache)
  final SupabaseClient _supabase = Supabase.instance.client;
  final RealTimeService _simulatorService;

  CardRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheSource,
    required RealTimeService simulatorService,
  }) : _simulatorService = simulatorService;

  @override
  Future<Either<Failure, List<CardItem>>> getCards(String columnId) async {
    try {
      // 1. Intentamos traer de Supabase para refrescar la caché
      try {
        final remoteCards = await remoteDataSource.getCards(columnId);
        // Actualizamos la caché local con lo que diga el servidor
        for (var card in remoteCards) {
          await _updateLocalCache(card);
        }
      } catch (_) {}

      // 2. Devolvemos lo que tengamos en la caché local
      final localCards = await localCacheSource.getCards(columnId);
      return Right(localCards);
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
      // Intentamos remoto primero para asegurar consistencia de IDs
      try {
        final remoteCard = await remoteDataSource.createCard(
          id: id,
          columnId: columnId,
          title: title,
          description: description,
          position: position,
          createdBy: createdBy,
          createdAt: createdAt,
        );
        
        await _updateLocalCache(remoteCard);
        return Right(remoteCard);
      } catch (e) {
        // Fallback offline
        final localCard = await localCacheSource.createCard(
          id: id,
          columnId: columnId,
          title: title,
          description: description,
          position: position,
          createdBy: createdBy,
          createdAt: createdAt,
        );
        return Right(localCard);
      }
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
    final cardModel = CardItemModel(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
    );

    try {
      await _updateLocalCache(cardModel);
      try {
        await remoteDataSource.updateCard(cardModel);
      } catch (_) {}
      return Right(cardModel);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(String cardId) async {
    try {
      await localCacheSource.deleteCard(cardId);
      try {
        await remoteDataSource.deleteCard(cardId);
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  // Helper para asegurar sincronización manual de la caché
  Future<void> _updateLocalCache(CardItem card) async {
    if (localCacheSource is FakeCardDatasource) {
       final db = (localCacheSource as FakeCardDatasource).database;
       final index = db.cards.indexWhere((c) => c.id == card.id);
       if (index != -1) {
         db.cards[index] = card;
       } else {
         db.cards.add(card);
       }
    }
  }

  @override
  Stream<RealTimeEvent> watchCards() {
    final simulatorStream = _simulatorService.eventStream;

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

        if (data != null && !controller.isClosed) {
          final card = CardItemModel.fromJson(data);
          
          if (type == RealTimeEventType.cardDeleted) {
            localCacheSource.deleteCard(card.id);
          } else {
            _updateLocalCache(card);
          }
          
          controller.add(RealTimeEvent(type, card));
        }
      },
    ).subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
      controller.close();
    };

    return MergeStream([simulatorStream, controller.stream]);
  }
}
