import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/real_time_service.dart';
import '../../domain/entities/board_member.dart';
import '../../domain/repositories/board_member_repository.dart';
import '../datasources/board_member_remote_datasource.dart';
import '../models/board_member_model.dart';

class BoardMemberRepositoryImpl implements BoardMemberRepository {
  final BoardMemberRemoteDataSource remoteDataSource; // Supabase
  final BoardMemberRemoteDataSource localCacheSource; // FakeDB (Cache)
  final SupabaseClient _supabase = Supabase.instance.client;
  final RealTimeService _simulatorService;

  BoardMemberRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheSource,
    required RealTimeService simulatorService,
  }) : _simulatorService = simulatorService;

  @override
  Future<Either<Failure, List<BoardMember>>> getBoardMembers(String boardId) async {
    try {
      try {
        final remoteMembers = await remoteDataSource.getBoardMembers(boardId);
        for (var member in remoteMembers) {
          // If we had an updateMember, we'd use it. For now, we sync via the local cache.
        }
      } catch (_) {}

      final localMembers = await localCacheSource.getBoardMembers(boardId);
      return Right(localMembers);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, BoardMember>> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
    required DateTime joinedAt,
  }) async {
    try {
      final localMember = await localCacheSource.addBoardMember(
        boardId: boardId,
        userId: userId,
        role: role,
        joinedAt: joinedAt,
      );

      try {
        final remoteMember = await remoteDataSource.addBoardMember(
          boardId: boardId,
          userId: userId,
          role: role,
          joinedAt: joinedAt,
        );
        return Right(remoteMember);
      } catch (e) {
        return Right(localMember);
      }
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeBoardMember({
    required String boardId,
    required String userId,
  }) async {
    try {
      await localCacheSource.removeBoardMember(boardId: boardId, userId: userId);
      try {
        await remoteDataSource.removeBoardMember(boardId: boardId, userId: userId);
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Stream<RealTimeEvent> watchBoardMembers() {
    final simulatorStream = _simulatorService.eventStream;

    final controller = StreamController<RealTimeEvent>();
    final channel = _supabase.channel('public:board_members');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'board_members',
      callback: (payload) {
        final eventType = payload.eventType;
        RealTimeEventType type;
        Map<String, dynamic>? data;

        if (eventType == PostgresChangeEvent.insert) {
          type = RealTimeEventType.memberAdded;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.update) {
          type = RealTimeEventType.memberUpdated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.delete) {
          type = RealTimeEventType.memberRemoved;
          data = payload.oldRecord;
        } else {
          return;
        }

        if (data != null && !controller.isClosed) {
          final member = BoardMemberModel.fromJson(data);
          
          if (type == RealTimeEventType.memberRemoved) {
            localCacheSource.removeBoardMember(boardId: member.boardId, userId: member.userId);
          }
          
          controller.add(RealTimeEvent(type, member));
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
