import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../comment/domain/entities/comment.dart';
import '../../domain/entities/card_item.dart';
import '../providers/card_notifier.dart';

final cardNotifierProvider =
AsyncNotifierProvider.family<
    CardNotifier,
    List<CardItem>,
    String>(
  CardNotifier.new,
);

class CreateCardDialog extends ConsumerStatefulWidget {
  final String columnId;

  const CreateCardDialog({
    super.key,
    required this.columnId,
  });

  @override
  ConsumerState<CreateCardDialog> createState() =>
      _CreateCardDialogState();
}

class _CreateCardDialogState
    extends ConsumerState<CreateCardDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _commentController = TextEditingController();

  final List<Comment> _comments = [];
  DateTime? _createdAt;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Card'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TITLE
              TextFormField(
                controller: _titleController,
                decoration:
                const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 12),

              // DESCRIPTION
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // TAG INPUT
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                          labelText: 'Add tag'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addComment,
                  )
                ],
              ),
              const SizedBox(height: 8),

              // TAGS PREVIEW
              Wrap(
                spacing: 6,
                children: _comments
                    .map(
                      (comment) => Chip(
                    label: Text(comment as String),
                    onDeleted: () {
                      setState(() {
                        _comments.remove(comment);
                      });
                    },
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 12),

              // DUE DATE
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _createdAt == null
                          ? 'No due date'
                          : 'Due: ${_createdAt!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
          _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : const Text('Create'),
        ),
      ],
    );
  }

  void _addComment() {
    final comment = _commentController.text.trim();

    if (comment.isNotEmpty && !_comments.contains(comment)) {
      setState(() {
        _comments.add(comment as Comment);
        _commentController.clear();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _createdAt = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    await ref
        .read(cardNotifierProvider(widget.columnId).notifier)
        .createCard(
      id: UniqueKey().toString(),
      columnId: widget.columnId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      position: 0, // TODO: Calcular posición real
      createdBy: 'currentUserId', // TODO: Obtener ID real del usuario
      createdAt: _createdAt,
      comments: _comments,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }
}