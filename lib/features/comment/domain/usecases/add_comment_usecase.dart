import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/comment_repository.dart';

class AddCommentUseCase {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
    String? parentId,
    List<String> mentionedUserIds = const [],
  }) {
    return repository.addComment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      parentId: parentId,
      mentionedUserIds: mentionedUserIds,
    );
  }
}
