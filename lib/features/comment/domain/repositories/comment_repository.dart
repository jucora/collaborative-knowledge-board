import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/real_time_service.dart';
import '../entities/comment.dart';

/// Abstract definition for Comment operations.
abstract class CommentRepository {

  /// Fetches all comments associated with a specific card.
  Future<Either<Failure, List<Comment>>> getCommentsByCard(String cardId);

  /// Adds a new comment to a card.
  Future<Either<Failure, void>> addComment({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
    String? parentId,
    List<String> mentionedUserIds = const [],
  });

  /// Updates an existing comment's content.
  Future<Either<Failure, void>> updateComment({
    required String id,
    required String content,
    required DateTime updatedAt,
    List<String> mentionedUserIds = const [],
  });

  /// Deletes a comment by its ID.
  Future<Either<Failure, void>> deleteComment(String commentId);

  /// Returns a stream of real-time events related to comments.
  Stream<RealTimeEvent> watchComments();
}
