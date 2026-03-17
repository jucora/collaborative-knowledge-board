import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/config_provider.dart'; // Importamos la config global
import '../../../comment/domain/entities/comment.dart';
import '../providers/card_notifier_provider.dart';

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

  late DateTime _createdAt = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: _comments.map((comment) {
                  return Chip(
                    label: Text(comment.content),
                    onDeleted: () {
                      setState(() {
                        _comments.remove(comment);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text('Due: ${_createdAt.toLocal().toString().split(' ')[0]}'),
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
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _createdAt = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      String creator = 'Dev User';
      if (!useFakeData) {
        final user = Supabase.instance.client.auth.currentUser;
        creator = user?.email ?? 'Anonymous';
      }
      
      final currentCards = ref.read(cardNotifierProvider(widget.columnId)).value ?? [];
      
      await ref.read(cardNotifierProvider(widget.columnId).notifier).createCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        position: currentCards.length,
        createdBy: creator,
        createdAt: _createdAt,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
