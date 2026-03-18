import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/real_time_service.dart';
import '../../domain/entities/board.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/board_remote_datasource.dart';
import '../datasources/fake_board_datasource.dart';
import '../models/board_model.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardRemoteDataSource remoteDataSource; // Supabase
  final BoardRemoteDataSource localCacheSource; // FakeDB (Cache)
  final SupabaseClient _supabase = Supabase.instance.client;
  final RealTimeService _simulatorService;

  BoardRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheSource,
    required RealTimeService simulatorService,
  }) : _simulatorService = simulatorService;

  @override
  Future<Either<Failure, List<Board>>> getBoards() async {
    try {
      // 1. Intentamos traer de Supabase para refrescar la caché
      try {
        final remoteBoards = await remoteDataSource.getBoards();
        
        // Sincronización completa de la caché:
        // Primero eliminamos tableros que ya no están en el servidor (opcional según política)
        // Y añadimos/actualizamos los nuevos.
        for (var board in remoteBoards) {
           await _updateLocalCache(board);
        }
      } catch (_) {}

      // 2. Devolvemos caché local
      final localBoards = await localCacheSource.getBoards();
      return Right(localBoards);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, Board>> createBoard({
    required String title,
    required String description,
  }) async {
    try {
      // 1. Remoto PRIMERO para obtener el ID real de Supabase (UUID)
      // En Boards, como es la raíz, preferimos tener el ID real pronto.
      try {
        final remoteBoard = await remoteDataSource.createBoard(
          title: title,
          description: description,
        );
        
        // 2. Guardamos en la caché local con el ID real
        await _updateLocalCache(remoteBoard);
        
        return Right(remoteBoard);
      } catch (e) {
        // Si falla el remoto (offline), creamos uno local temporal
        final localBoard = await localCacheSource.createBoard(
          title: title,
          description: description,
        );
        return Right(localBoard);
      }
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBoard(String id) async {
    try {
      await localCacheSource.deleteBoard(id);
      try {
        await remoteDataSource.deleteBoard(id);
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  // Helper para actualizar la caché local sin duplicados
  Future<void> _updateLocalCache(Board board) async {
    // Como el FakeBoardDataSource no tiene updateBoard, lo manejamos aquí
    // borrando y añadiendo si es necesario, o confiando en el datasource.
    if (localCacheSource is FakeBoardDataSource) {
       final db = (localCacheSource as FakeBoardDataSource).database;
       final index = db?.boards.indexWhere((b) => b.id == board.id) ?? -1;
       if (index != -1) {
         db?.boards[index] = board;
       } else {
         db?.boards.add(board);
       }
    }
  }

  @override
  Stream<RealTimeEvent> watchBoards() {
    final simulatorStream = _simulatorService.eventStream;

    final controller = StreamController<RealTimeEvent>();
    final channel = _supabase.channel('public:boards');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'boards',
      callback: (payload) {
        final eventType = payload.eventType;
        RealTimeEventType type;
        Map<String, dynamic>? data;

        if (eventType == PostgresChangeEvent.insert) {
          type = RealTimeEventType.boardCreated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.update) {
          type = RealTimeEventType.boardUpdated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.delete) {
          type = RealTimeEventType.boardDeleted;
          data = payload.oldRecord;
        } else {
          return;
        }

        if (data != null && !controller.isClosed) {
          final board = BoardModel.fromJson(data);
          
          if (type == RealTimeEventType.boardDeleted) {
            localCacheSource.deleteBoard(board.id);
          } else {
            _updateLocalCache(board);
          }
          
          controller.add(RealTimeEvent(type, board));
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
