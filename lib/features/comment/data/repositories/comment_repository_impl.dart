import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/real_time_service.dart';
import '../datasources/fake_comment_datasource.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource; // Supabase
  final CommentRemoteDataSource localCacheSource; // FakeDB (Cache)
  final SupabaseClient _supabase = Supabase.instance.client;
  final RealTimeService _simulatorService;

  CommentRepositoryImpl({
    required this.remoteDataSource,
    required this.localCacheSource,
    required RealTimeService simulatorService,
  }) : _simulatorService = simulatorService;

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByCard(String cardId) async {
    try {
      try {
        final remoteComments = await remoteDataSource.getComments(cardId);
        for (var comment in remoteComments) {
          await _updateLocalCache(comment);
        }
      } catch (_) {}

      final localComments = await localCacheSource.getComments(cardId);
      return Right(localComments);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> addComment({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
    String? parentId,
    List<String> mentionedUserIds = const [],
  }) async {
    final comment = CommentModel(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      parentId: parentId,
      mentionedUserIds: mentionedUserIds,
    );

    try {
      // Intentamos remoto primero para IDs consistentes
      try {
        final remoteComment = await remoteDataSource.addComment(comment);
        await _updateLocalCache(remoteComment);
        return const Right(null);
      } catch (e) {
        // Fallback offline
        await localCacheSource.addComment(comment);
        return const Right(null);
      }
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateComment({
    required String id,
    required String content,
    required DateTime updatedAt,
    List<String> mentionedUserIds = const [],
  }) async {
    final partialUpdate = CommentModel(
      id: id,
      cardId: "", 
      authorId: "", 
      content: content,
      createdAt: DateTime.now(), 
      updatedAt: updatedAt,
      mentionedUserIds: mentionedUserIds,
    );

    try {
      await _updateLocalCache(partialUpdate);
      try {
        await remoteDataSource.updateComment(partialUpdate);
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await localCacheSource.deleteComment(commentId);
      try {
        await remoteDataSource.deleteComment(commentId);
      } catch (_) {}
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  // Helper para sincronización de caché manual
  Future<void> _updateLocalCache(Comment comment) async {
    if (localCacheSource is FakeCommentDataSource) {
       final db = (localCacheSource as FakeCommentDataSource).database;
       final index = db.comments.indexWhere((c) => c.id == comment.id);
       if (index != -1) {
         db.comments[index] = comment;
       } else {
         db.comments.add(comment);
       }
    }
  }

  @override
  Stream<RealTimeEvent> watchComments() {
    final simulatorStream = _simulatorService.eventStream;

    final controller = StreamController<RealTimeEvent>();
    final channel = _supabase.channel('public:comments');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comments',
      callback: (payload) {
        final eventType = payload.eventType;
        RealTimeEventType type;
        Map<String, dynamic>? data;

        if (eventType == PostgresChangeEvent.insert) {
          type = RealTimeEventType.commentCreated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.update) {
          type = RealTimeEventType.commentUpdated;
          data = payload.newRecord;
        } else if (eventType == PostgresChangeEvent.delete) {
          type = RealTimeEventType.commentDeleted;
          data = payload.oldRecord;
        } else {
          return;
        }

        if (data != null && !controller.isClosed) {
          final comment = CommentModel.fromJson(data);
          
          if (type == RealTimeEventType.commentDeleted) {
            localCacheSource.deleteComment(comment.id);
          } else {
            _updateLocalCache(comment);
          }
          
          controller.add(RealTimeEvent(type, comment));
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
