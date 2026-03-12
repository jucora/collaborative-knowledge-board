import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_item.dart';
import '../../../comment/presentation/widgets/comment_thread_widget.dart';
import '../../../comment/presentation/providers/comment_notifier_provider.dart';

class CardDetailDialog extends ConsumerWidget {
  final CardItem card;

  const CardDetailDialog({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title and Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    card.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Created by ${card.createdBy}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const Divider(height: 32),
            
            // Description Section
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              card.description.isNotEmpty ? card.description : "No description provided.",
              style: const TextStyle(fontSize: 16),
            ),
            
            const Divider(height: 32),
            
            // Comments Section Header
            const Row(
              children: [
                Icon(Icons.comment_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  "Comments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // New Comment Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      ref.read(commentNotifierProvider(card.id).notifier).createComment(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        cardId: card.id,
                        authorId: "Current User", // In a real app, use auth state
                        content: commentController.text,
                        createdAt: DateTime.now(),
                      );
                      commentController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Threaded Comments List
            Expanded(
              child: SingleChildScrollView(
                child: CommentThreadWidget(cardId: card.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
