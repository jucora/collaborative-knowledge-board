import 'package:collaborative_knowledge_board/features/comment/domain/usecases/get_comments_usecase.dart';
import 'package:collaborative_knowledge_board/features/comment/presentation/providers/comment_usecase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';

class CommentNotifier extends FamilyAsyncNotifier<List<Comment>, String> {

  late final GetCommentsUseCase getCommentsUseCase;

  @override
  Future<List<Comment>> build(String cardId) async {

    getCommentsUseCase = ref.read(getCommentsUseCaseProvider);

    final result = await getCommentsUseCase(cardId);

    return result.fold(
          (failure) => throw failure,
          (comments) => comments,
    );
  }

  Future<void> refreshComments() async {

    state = const AsyncLoading<List<Comment>>()
        .copyWithPrevious(state);

    final result = await getCommentsUseCase(arg);

    result.fold(
          (failure) => state = AsyncError(failure, StackTrace.current),
          (comments) => state = AsyncData(comments),
    );
  }

  Future<void> createComment({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
  }) async {

    final createComment = ref.read(addCommentUseCaseProvider);

    await createComment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
    );

    await refreshComments();
  }
}