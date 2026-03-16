import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_item.dart';
import '../providers/card_notifier_provider.dart';

class CardDetailDialog extends ConsumerWidget {
  final CardItem card;

  const CardDetailDialog({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(card.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(card.description.isEmpty ? 'No description provided.' : card.description),
            const SizedBox(height: 16),
            Text(
              'Created by: ${card.createdBy}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Created at: ${card.createdAt.toLocal().toString().split('.')[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        // DELETE BUTTON
        TextButton.icon(
          onPressed: () => _showDeleteConfirmDialog(context, ref),
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text('Delete Card', style: TextStyle(color: Colors.red)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
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
              // Call delete on the notifier
              ref.read(cardNotifierProvider(card.columnId).notifier).deleteCard(card.id);
              
              Navigator.pop(confirmContext); // Close confirm
              Navigator.pop(context); // Close detail dialog
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
