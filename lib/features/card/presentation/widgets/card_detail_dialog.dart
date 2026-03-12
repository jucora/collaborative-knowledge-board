import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_item.dart';
import '../../../comment/presentation/widgets/comment_thread_widget.dart';
import '../../../comment/presentation/providers/comment_notifier_provider.dart';

/// Card detail dialog optimized for performance.
/// 
/// PERFORMANCE OPTIMIZATIONS:
/// 1. Localizes state for the comment input to avoid rebuilding the whole dialog.
/// 2. Uses [const] constructors for static UI elements.
class CardDetailDialog extends ConsumerWidget {
  final CardItem card;

  const CardDetailDialog({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(card: card),
            const SizedBox(height: 8),
            Text(
              "Created by ${card.createdBy}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const Divider(height: 32),
            
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
            
            const _CommentSectionHeader(),
            const SizedBox(height: 16),
            
            _CommentInput(cardId: card.id),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                // PERFORMANCE: CommentThreadWidget also uses internal virtualization
                child: CommentThreadWidget(cardId: card.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CardItem card;
  const _Header({required this.card});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _CommentSectionHeader extends StatelessWidget {
  const _CommentSectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.comment_outlined, size: 20),
        SizedBox(width: 8),
        Text(
          "Comments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _CommentInput extends ConsumerStatefulWidget {
  final String cardId;
  const _CommentInput({required this.cardId});

  @override
  ConsumerState<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<_CommentInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.isNotEmpty) {
      ref.read(commentNotifierProvider(widget.cardId).notifier).createComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardId: widget.cardId,
        authorId: "Current User",
        content: _controller.text,
        createdAt: DateTime.now(),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Add a comment...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const Icon(Icons.send),
          onPressed: _submit,
        ),
      ],
    );
  }
}
