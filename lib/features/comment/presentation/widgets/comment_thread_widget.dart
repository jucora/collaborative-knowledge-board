import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/config_provider.dart';
import '../../domain/entities/comment.dart';
import '../providers/comment_notifier_provider.dart';

/// A widget that displays a list of comments in a threaded (nested) format.
class CommentThreadWidget extends ConsumerWidget {
  final String cardId;

  const CommentThreadWidget({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentNotifierProvider(cardId));

    return commentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (comments) {
        // Filter top-level comments (those without a parent)
        final rootComments = comments.where((c) => c.parentId == null).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rootComments.length,
          itemBuilder: (context, index) {
            return _CommentItem(
              comment: rootComments[index],
              allComments: comments,
              cardId: cardId,
            );
          },
        );
      },
    );
  }
}

class _CommentItem extends ConsumerWidget {
  final Comment comment;
  final List<Comment> allComments;
  final String cardId;
  final int depth;

  const _CommentItem({
    required this.comment,
    required this.allComments,
    required this.cardId,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find replies to this comment
    final replies = allComments.where((c) => c.parentId == comment.id).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 24.0, top: 8, bottom: 4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: depth == 0 ? Colors.grey.shade50 : Colors.blue.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.authorId,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      "${comment.createdAt.hour}:${comment.createdAt.minute}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _CommentContent(content: comment.content),
                if (comment.isEdited)
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text("(edited)", style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.reply,
                      label: "Reply",
                      onPressed: () => _showReplyDialog(context, ref),
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.edit,
                      label: "Edit",
                      onPressed: () => _showEditDialog(context, ref),
                    ),
                    const Spacer(),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: "Delete",
                      color: Colors.red.shade300,
                      onPressed: () => _showDeleteConfirm(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Render replies recursively
        ...replies.map((reply) => _CommentItem(
              comment: reply,
              allComments: allComments,
              cardId: cardId,
              depth: depth + 1,
            )),
      ],
    );
  }

  void _showReplyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reply to ${comment.authorId}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Write your reply... Use @user to mention"),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // FIX: Determine correct authorId (UUID for Supabase, String for Fake)
              String authorId = 'FakeUserId';
              if (!useFakeData) {
                authorId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
              }

              ref.read(commentNotifierProvider(cardId).notifier).createComment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                cardId: cardId,
                authorId: authorId,
                content: controller.text,
                createdAt: DateTime.now(),
                parentId: comment.id,
              );
              Navigator.pop(context);
            },
            child: const Text("Reply"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: comment.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Comment"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              ref.read(commentNotifierProvider(cardId).notifier).updateComment(
                id: comment.id,
                content: controller.text,
                updatedAt: DateTime.now(),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment?"),
        content: const Text("This will also delete all replies to this comment."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(commentNotifierProvider(cardId).notifier).deleteComment(comment.id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CommentContent extends StatelessWidget {
  final String content;
  const _CommentContent({required this.content});

  @override
  Widget build(BuildContext context) {
    // Basic Mention Highlighter
    final words = content.split(' ');
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: words.map((word) {
          final isMention = word.startsWith('@');
          return TextSpan(
            text: "$word ",
            style: TextStyle(
              color: isMention ? Colors.blue : Colors.black87,
              fontWeight: isMention ? FontWeight.bold : FontWeight.normal,
              backgroundColor: isMention ? Colors.blue.shade50 : Colors.transparent,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.blueGrey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color ?? Colors.blueGrey)),
        ],
      ),
    );
  }
}
