import 'dart:async';
import 'package:collaborative_knowledge_board/core/services/real_time_service.dart';
import 'package:collaborative_knowledge_board/features/comment/domain/usecases/get_comments_usecase.dart';
import 'package:collaborative_knowledge_board/features/comment/presentation/providers/comment_repository_provider.dart';
import 'package:collaborative_knowledge_board/features/comment/presentation/providers/comment_usecase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';

/// Notifier responsible for managing comments for a specific card.
class CommentNotifier extends FamilyAsyncNotifier<List<Comment>, String> {

  late GetCommentsUseCase getCommentsUseCase;
  StreamSubscription? _subscription;
  late String cardId;

  @override
  Future<List<Comment>> build(String arg) async {
    cardId = arg;
    getCommentsUseCase = ref.read(getCommentsUseCaseProvider);

    final repository = ref.read(commentRepositoryProvider);
    _subscription?.cancel();
    _subscription = repository.watchComments().listen(_handleRealTimeEvent);

    final result = await getCommentsUseCase(cardId);

    return result.fold(
          (failure) => throw failure,
          (comments) => comments,
    );
  }

  void _handleRealTimeEvent(RealTimeEvent event) {
    if (event.data == null) {
      ref.invalidateSelf();
      return;
    }

    state = state.whenData((comments) {
      if (event.type == RealTimeEventType.commentCreated) {
        final comment = event.data as Comment;
        if (comment.cardId == cardId && !comments.any((c) => c.id == comment.id)) {
          return [...comments, comment];
        }
      } else if (event.type == RealTimeEventType.commentUpdated) {
        final updatedComment = event.data as Comment;
        return comments.map((c) => c.id == updatedComment.id ? updatedComment : c).toList();
      } else if (event.type == RealTimeEventType.commentDeleted) {
        final commentId = event.data as String;
        return comments.where((c) => c.id != commentId).toList();
      }
      return comments;
    });
  }

  Future<void> createComment({
    required String id,
    required String cardId,
    required String authorId,
    required String content,
    required DateTime createdAt,
    String? parentId,
    List<String> mentionedUserIds = const [],
  }) async {
    final addComment = ref.read(addCommentUseCaseProvider);

    await addComment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      parentId: parentId,
      mentionedUserIds: mentionedUserIds,
    );
  }

  Future<void> updateComment({
    required String id,
    required String content,
    required DateTime updatedAt,
    List<String> mentionedUserIds = const [],
  }) async {
    // 1. Get existing comment from state
    final currentComments = state.value;
    if (currentComments == null) return;
    
    final index = currentComments.indexWhere((c) => c.id == id);
    if (index == -1) return;
    
    final existing = currentComments[index];
    
    // 2. Create updated comment entity
    final updated = existing.copyWith(
      content: content,
      updatedAt: updatedAt,
      mentionedUserIds: mentionedUserIds,
    );

    // 3. Persist via repository
    final repository = ref.read(commentRepositoryProvider);
    await repository.updateComment(
      id: updated.id,
      content: updated.content,
      updatedAt: updated.updatedAt!,
      mentionedUserIds: updated.mentionedUserIds,
    );
    
    // 4. Update UI immediately (Optimistic)
    state = AsyncData(
      currentComments.map((c) => c.id == id ? updated : c).toList()
    );
  }

  Future<void> deleteComment(String commentId) async {
    final repository = ref.read(commentRepositoryProvider);
    await repository.deleteComment(commentId);
    
    state = state.whenData(
      (comments) => comments.where((c) => c.id != commentId).toList(),
    );
  }
}
