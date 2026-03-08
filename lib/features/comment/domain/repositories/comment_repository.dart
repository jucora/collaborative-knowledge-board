import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment.dart';

abstract class CommentRepository {

  Future<Either<Failure, List<Comment>>> getCommentsByCard(String cardId);

  Future<Either<Failure, void>> addComment({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
  });
}