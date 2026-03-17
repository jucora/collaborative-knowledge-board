import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/real_time_service.dart';
import '../datasources/board_column_remote_datasource.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/repositories/board_column_repository.dart';
import '../models/board_column_model.dart';

class BoardColumnRepositoryImpl implements BoardColumnRepository {
  final BoardColumnRemoteDataSource remoteDataSource; // Supabase
  final BoardColumnRemoteDataSource localCacheSource; // FakeDB (Cache)
  final SupabaseClient _supabase = Supabase.instance.client;
  final RealTimeService _simulatorService;

  BoardColumnRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheSource,
    required RealTimeService simulatorService,
  }) : _simulatorService = simulatorService;

  @override
  Future<Either<Failure, List<BoardColumn>>> getBoardColumns(String boardId) async {
    try {
      try {
        final remoteCols = await remoteDataSource.getBoardColumns(boardId);
        for (var col in remoteCols) {
          await localCacheSource.updateBoardColumn(col);
        }
      } catch (_) {}

      final localCols = await localCacheSource.getBoardColumns(boardId);
      return Right(localCols);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, BoardColumn>> createBoardColumn({
    required String boardId,
    required String title,
    required int position,
  }) async {
    try {
      final localCol = await localCacheSource.createBoardColumn(
        boardId: boardId,
        title: title,
        position: position,
      );

      try {
        final remoteCol = await remoteDataSource.createBoardColumn(
          boardId: boardId,
          title: title,
          position: position,
        );
        return Right(remoteCol);
      } catch (e) {
        return Right(localCol);
      }
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateBoardColumn(BoardColumn column) async {
    final model = BoardColumnModel.fromEntity(column);
    try {
      await localCacheSource.updateBoardColumn(model);
      try {
        await remoteDataSource.updateBoardColumn(model);
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBoardColumn(String columnId) async {
    try {
      await localCacheSource.deleteBoardColumn(columnId);
      try {
        await remoteDataSource.deleteBoardColumn(columnId);
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Stream<RealTimeEvent> watchBoardColumns() {
    final simulatorStream = _simulatorService.eventStream;

    final controller = StreamController<RealTimeEvent>();
    final channel = _supabase.channel('public:board_columns');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'board_columns',
      callback: (payload) {
        final eventType = payload.eventType;
        RealTimeEventType type;
        Map<String, dynamic>? data;

        if (eventType == PostgresChangeEvent.insert) {
          type = RealTimeEventType.columnCreated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.update) {
          type = RealTimeEventType.columnUpdated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.delete) {
          type = RealTimeEventType.columnDeleted;
          data = payload.oldRecord;
        } else {
          return;
        }

        if (data != null && !controller.isClosed) {
          final col = BoardColumnModel.fromJson(data);
          
          if (type == RealTimeEventType.columnDeleted) {
            localCacheSource.deleteBoardColumn(col.id);
          } else {
            localCacheSource.updateBoardColumn(col);
          }
          
          controller.add(RealTimeEvent(type, col));
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
