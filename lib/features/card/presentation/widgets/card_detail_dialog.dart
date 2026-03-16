import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/config_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../comment/presentation/providers/comment_notifier_provider.dart';
import '../../../comment/presentation/widgets/comment_thread_widget.dart';
import '../../domain/entities/card_item.dart';
import '../providers/card_notifier_provider.dart';

class CardDetailDialog extends ConsumerStatefulWidget {
  final CardItem card;

  const CardDetailDialog({
    super.key,
    required this.card,
  });

  @override
  ConsumerState<CardDetailDialog> createState() => _CardDetailDialogState();
}

class _CardDetailDialogState extends ConsumerState<CardDetailDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _newCommentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.card.title);
    _descriptionController = TextEditingController(text: widget.card.description);
    _newCommentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: _isEditing 
        ? const Text("Edit Card") 
        : Text(widget.card.title),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing) ...[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
              ] else ...[
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.card.description.isEmpty ? 'No description provided.' : widget.card.description),
                const SizedBox(height: 16),
                Text(
                  'Created by: ${widget.card.createdBy}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Created at: ${widget.card.createdAt.toLocal().toString().split('.')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 32),
                const Text(
                  'Comments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCommentController,
                        decoration: const InputDecoration(
                          hintText: "Write a comment...",
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded),
                      onPressed: _submitComment,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                CommentThreadWidget(cardId: widget.card.id),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (_isEditing) ...[
          TextButton(
            onPressed: () => setState(() => _isEditing = false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveChanges,
            child: const Text('Save'),
          ),
        ] else ...[
          // Correct implementation of horizontal layout for actions 
          // to avoid Spacer/Expanded errors in AlertDialog
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _showDeleteConfirmDialog(context, ref),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => setState(() => _isEditing = true),
                    tooltip: "Edit Card",
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _submitComment() async {
    final text = _newCommentController.text.trim();
    if (text.isEmpty) return;

    String authorId = 'FakeUserId';
    if (!useFakeData) {
      authorId = Supabase.instance.client.auth.currentUser?.id ?? 'anonymous';
    }

    try {
      await ref.read(commentNotifierProvider(widget.card.id).notifier).createComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cardId: widget.card.id,
        authorId: authorId,
        content: text,
        createdAt: DateTime.now(),
      );
      _newCommentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    }
  }

  void _saveChanges() async {
    if (_titleController.text.trim().isEmpty) return;

    await ref.read(cardNotifierProvider(widget.card.columnId).notifier).editCard(
      cardId: widget.card.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (mounted) setState(() => _isEditing = false);
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (confirmContext) => AlertDialog(
        title: const Text('Delete Card?'),
        content: const Text('Are you sure you want to permanently delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(confirmContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cardNotifierProvider(widget.card.columnId).notifier).deleteCard(widget.card.id);
              Navigator.pop(confirmContext);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
