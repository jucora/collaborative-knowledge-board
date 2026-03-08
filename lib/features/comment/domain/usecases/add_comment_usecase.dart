import 'package:collaborative_knowledge_board/features/comment/domain/repositories/comment_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class AddCommentUseCase {
  CommentRepository commentRepository;

  AddCommentUseCase(this.commentRepository);

  Future<Either<Failure, void>> call({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
  }) async {
    final result = await commentRepository.addComment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
    );

    return result;
  }
}