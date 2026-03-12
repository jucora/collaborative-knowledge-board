import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/sync_service.dart';
import '../../../card/domain/entities/card_item.dart';
import '../../../card/presentation/providers/card_notifier_provider.dart';
import '../../../card/presentation/widgets/card_detail_dialog.dart';
import '../../domain/entities/board_column.dart';

/// Optimized and Responsive widget for Board Columns.
class BoardColumnWidget extends ConsumerWidget {
  final BoardColumn column;

  const BoardColumnWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardNotifierProvider(column.id));
    
    // RESPONSIVE DESIGN:
    // On small screens (mobile), columns take up 85% of the width.
    // On larger screens, they stay at a comfortable 300px.
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = screenWidth < 600 ? screenWidth * 0.85 : 300.0;

    return DragTarget<CardItem>(
      onWillAcceptWithDetails: (details) => details.data.columnId != column.id,
      onAcceptWithDetails: (details) async {
        final draggedCard = details.data;
        final updatedCard = draggedCard.copyWith(columnId: column.id);
        ref.read(cardNotifierProvider(column.id).notifier).addCardLocally(updatedCard);
        await ref.read(cardNotifierProvider(draggedCard.columnId).notifier).updateCard(updatedCard);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: columnWidth,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05) 
                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${column.title[0].toUpperCase()}", // Simple icon/initial
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        column.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: cardsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (cards) {
                    return ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) {
                        ref.read(cardNotifierProvider(column.id).notifier).reorderCards(oldIndex, newIndex);
                      },
                      itemCount: cards.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      cacheExtent: 500,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return _DraggableCardWrapper(
                          key: ValueKey(card.id), 
                          card: card,
                          width: columnWidth - 20, // Adjust card width to column
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableCardWrapper extends StatelessWidget {
  final CardItem card;
  final double width;
  const _DraggableCardWrapper({super.key, required this.card, required this.width});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<CardItem>(
      data: card,
      feedback: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          child: Text(
            card.title,
            style: const TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _CardItem(card: card),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => CardDetailDialog(card: card),
          );
        },
        child: _CardItem(card: card),
      ),
    );
  }
}

class _CardItem extends ConsumerWidget {
  final CardItem card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = ref.watch(syncServiceProvider.select(
      (sync) => sync.pendingActions.any(
        (action) => (action.data is CardItem && (action.data as CardItem).id == card.id)
      )
    ));

    return Card(
      elevation: isPending ? 0 : 0.5,
      color: isPending ? Colors.amber.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isPending ? Colors.black54 : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isPending)
                  const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
