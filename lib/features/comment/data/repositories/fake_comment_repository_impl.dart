import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:collaborative_knowledge_board/core/services/real_time_service.dart';
import 'package:collaborative_knowledge_board/features/comment/domain/entities/comment.dart';
import 'package:dartz/dartz.dart';
import '../../../card/data/datasources/fake_card_datasource.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/fake_comment_datasource.dart';

class FakeCommentRepositoryImpl extends CommentRepository {
  final FakeCardDatasource cardDataSource;
  final FakeCommentDataSource commentDataSource;
  final RealTimeService realTimeService;

  FakeCommentRepositoryImpl(
    this.cardDataSource,
    this.commentDataSource,
    this.realTimeService,
  );

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
      final newComment = Comment(
        id: id,
        cardId: cardId,
        authorId: authorId,
        content: content,
        createdAt: createdAt,
        parentId: parentId,
        mentionedUserIds: mentionedUserIds,
      );

      await commentDataSource.addComment(newComment);
      realTimeService.notify(RealTimeEventType.commentCreated, newComment);

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to add comment'));
    }
  }

  @override
  Future<Either<Failure, void>> updateComment({
    required String id,
    required String content,
    required DateTime updatedAt,
    List<String> mentionedUserIds = const [],
  }) async {
    try {
      // Get existing comment to keep other fields
      final comments = await commentDataSource.database.comments;
      final existingIndex = comments.indexWhere((c) => c.id == id);
      if (existingIndex == -1) return const Left(ServerFailure('Comment not found'));

      final updatedComment = comments[existingIndex].copyWith(
        content: content,
        updatedAt: updatedAt,
        mentionedUserIds: mentionedUserIds,
      );

      await commentDataSource.updateComment(updatedComment);
      realTimeService.notify(RealTimeEventType.commentUpdated, updatedComment);

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to update comment'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await commentDataSource.deleteComment(commentId);
      realTimeService.notify(RealTimeEventType.commentDeleted, commentId);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to delete comment'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByCard(String cardId) async {
    try {
      final comments = await commentDataSource.getCommentsByCard(cardId);
      return Right(comments);
    } catch (e) {
      return const Left(ServerFailure('Failed to load comments'));
    }
  }

  @override
  Stream<RealTimeEvent> watchComments() {
    return realTimeService.eventStream.where((event) =>
        event.type == RealTimeEventType.commentCreated ||
        event.type == RealTimeEventType.commentUpdated ||
        event.type == RealTimeEventType.commentDeleted);
  }
}
