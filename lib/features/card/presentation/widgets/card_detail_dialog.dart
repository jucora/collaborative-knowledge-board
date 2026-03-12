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
    // RESPONSIVE DIALOG:
    // Full screen on mobile, 80% on desktop.
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: EdgeInsets.all(isMobile ? 12 : 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 20 : 16)),
      child: Container(
        width: isMobile ? screenWidth : screenWidth * 0.7,
        height: MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.8),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(card: card),
            const SizedBox(height: 8),
            Text(
              "Created by ${card.createdBy}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const Divider(height: 32),
            
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              card.description.isNotEmpty ? card.description : "No description provided.",
              style: const TextStyle(fontSize: 15),
            ),
            
            const Divider(height: 32),
            
            const _CommentSectionHeader(),
            const SizedBox(height: 12),
            
            _CommentInput(cardId: card.id),
            const SizedBox(height: 16),
            
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  child: CommentThreadWidget(cardId: card.id),
                ),
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
        Icon(Icons.chat_bubble_outline, size: 18),
        SizedBox(width: 8),
        Text(
          "Conversation",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
        authorId: "You",
        content: _controller.text,
        createdAt: DateTime.now(),
      );
      _controller.clear();
      FocusScope.of(context).unfocus(); // Close keyboard on mobile
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const Icon(Icons.send_rounded),
          onPressed: _submit,
        ),
      ],
    );
  }
}
