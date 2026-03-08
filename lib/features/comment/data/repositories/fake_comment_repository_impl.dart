import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:collaborative_knowledge_board/features/comment/domain/entities/comment.dart';
import 'package:dartz/dartz.dart';
import '../../../card/data/datasources/fake_card_datasource.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/fake_comment_datasource.dart';

class FakeCommentRepositoryImpl extends CommentRepository {

  FakeCardDatasource cardDataSource;
  FakeCommentDataSource commentDataSource;

  FakeCommentRepositoryImpl(
      this.cardDataSource,
      this.commentDataSource,
      );

  @override
  Future<Either<Failure, void>> addComment({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
  }) async {

    final newComment = Comment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
    );

    final comments = await commentDataSource.getCommentsByCard(cardId);
    comments.add(newComment);
    await commentDataSource.addComments(comments);

    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByCard(String cardId) {
    // TODO: implement getCommentsByCard
    throw UnimplementedError();
  }
}