import 'dart:async';
import 'package:collaborative_knowledge_board/core/services/real_time_service.dart';
import 'package:collaborative_knowledge_board/features/comment/domain/usecases/get_comments_usecase.dart';
import 'package:collaborative_knowledge_board/features/comment/presentation/providers/comment_repository_provider.dart';
import 'package:collaborative_knowledge_board/features/comment/presentation/providers/comment_usecase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';

/// Notifier responsible for managing comments for a specific card.
class CommentNotifier extends FamilyAsyncNotifier<List<Comment>, String> {

  late final GetCommentsUseCase getCommentsUseCase;
  StreamSubscription? _subscription;
  late String cardId;

  @override
  Future<List<Comment>> build(String arg) async {
    cardId = arg;
    getCommentsUseCase = ref.read(getCommentsUseCaseProvider);

    // START: Real-Time Implementation
    // Listen for new comments in real-time.
    final repository = ref.read(commentRepositoryProvider);
    _subscription?.cancel();
    _subscription = repository.watchComments().listen(_handleRealTimeEvent);
    // END: Real-Time Implementation

    final result = await getCommentsUseCase(cardId);

    return result.fold(
          (failure) => throw failure,
          (comments) => comments,
    );
  }

  /// Handles incoming real-time comment events.
  void _handleRealTimeEvent(RealTimeEvent event) {
    if (event.data == null) {
      // Refresh data if connection is recovered.
      ref.invalidateSelf();
      return;
    }

    if (event.type == RealTimeEventType.commentCreated) {
      final comment = event.data as Comment;
      // Only update if the comment belongs to the card this notifier is watching.
      if (comment.cardId == cardId) {
        state = state.whenData((comments) {
          // Avoid duplicate comments in the UI.
          if (comments.any((c) => c.id == comment.id)) return comments;
          return [...comments, comment];
        });
      }
    }
  }

  /// Manually re-fetches comments from the repository.
  Future<void> refreshComments() async {
    state = const AsyncLoading<List<Comment>>()
        .copyWithPrevious(state);

    final result = await getCommentsUseCase(cardId);

    result.fold(
          (failure) => state = AsyncError(failure, StackTrace.current),
          (comments) => state = AsyncData(comments),
    );
  }

  /// Sends a new comment to the repository.
  Future<void> createComment({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
  }) async {

    final addComment = ref.read(addCommentUseCaseProvider);

    await addComment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
    );
    
    // Note: The UI update is handled by the real-time stream subscription in _handleRealTimeEvent.
  }
}