import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/sync_service.dart';
import '../../../card/domain/entities/card_item.dart';
import '../../../card/presentation/providers/card_notifier_provider.dart';
import '../../../card/presentation/widgets/card_detail_dialog.dart';
import '../../domain/entities/board_column.dart';

/// Optimized widget for Board Columns.
/// 
/// PERFORMANCE OPTIMIZATIONS:
/// 1. Uses [ReorderableListView.builder] for virtualization of cards.
/// 2. Extracted [_CardItem] as a separate [ConsumerWidget] to localize rebuilds
///    when sync status changes.
class BoardColumnWidget extends ConsumerWidget {
  final BoardColumn column;

  const BoardColumnWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds the column when the list of cards changes (count or identity), 
    // not when a single card's content or sync status changes.
    final cardsAsync = ref.watch(cardNotifierProvider(column.id));

    return DragTarget<CardItem>(
      onWillAcceptWithDetails: (details) => details.data.columnId != column.id,
      onAcceptWithDetails: (details) async {
        final draggedCard = details.data;
        final updatedCard = draggedCard.copyWith(columnId: column.id);

        ref.read(cardNotifierProvider(column.id).notifier).addCardLocally(updatedCard);

        await ref
            .read(cardNotifierProvider(draggedCard.columnId).notifier)
            .updateCard(updatedCard);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  column.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              Expanded(
                child: cardsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (cards) {
                    // PERFORMANCE: Builder constructor is essential for 200+ cards
                    return ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) {
                        ref.read(cardNotifierProvider(column.id).notifier)
                            .reorderCards(oldIndex, newIndex);
                      },
                      itemCount: cards.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      // Cache Extent improves scrolling smoothness by pre-rendering 
                      // items slightly outside the viewport.
                      cacheExtent: 500, 
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return _DraggableCardWrapper(key: ValueKey(card.id), card: card);
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

/// Helper widget to encapsulate Draggable logic and avoid rebuilding the whole list.
class _DraggableCardWrapper extends StatelessWidget {
  final CardItem card;
  const _DraggableCardWrapper({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<CardItem>(
      data: card,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
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

/// A presentational widget for the card's UI.
/// 
/// PERFORMANCE: This widget only watches the specific action related to its ID.
class _CardItem extends ConsumerWidget {
  final CardItem card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERFORMANCE: By selecting only the pending status of THIS card, 
    // this widget won't rebuild when OTHER cards are being synced.
    final isPending = ref.watch(syncServiceProvider.select(
      (sync) => sync.pendingActions.any(
        (action) => (action.data is CardItem && (action.data as CardItem).id == card.id)
      )
    ));

    return Card(
      elevation: isPending ? 0.5 : 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isPending ? Colors.amber.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    card.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isPending ? Colors.black54 : Colors.black,
                    ),
                  ),
                ),
                if (isPending)
                  const Tooltip(
                    message: "Pending sync...",
                    child: Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.amber),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
