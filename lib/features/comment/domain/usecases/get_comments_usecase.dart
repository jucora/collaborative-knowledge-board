import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetCommentsUseCase {

  CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<Either<Failure, List<Comment>>> call(String cardId) async {
    final result = await repository.getCommentsByCard(cardId);
    return result;
  }
}