import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/providers/config_provider.dart';
import '../../../../core/services/real_time_service.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;
  final SupabaseClient _supabase = Supabase.instance.client;

  CommentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByCard(String cardId) async {
    try {
      final models = await remoteDataSource.getComments(cardId);
      return Right(models);
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
    try {
      final comment = CommentModel(
        id: id,
        cardId: cardId,
        authorId: authorId,
        content: content,
        createdAt: createdAt,
        parentId: parentId,
        mentionedUserIds: mentionedUserIds,
      );
      await remoteDataSource.addComment(comment);
      return const Right(null);
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
    // Note: For now, we update via a generic add/update if needed, 
    // or you could add updateComment to the DataSource.
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Stream<RealTimeEvent> watchComments() {
    if (useFakeData) return const Stream.empty();

    return _supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .map((_) => RealTimeEvent(RealTimeEventType.commentUpdated, null));
  }
}
