import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../card/domain/entities/card_item.dart';
import '../../../card/presentation/providers/card_notifier_provider.dart';
import '../../domain/entities/board_column.dart';

/// This widget represents an entire column on the Kanban board.
/// 
/// It coordinates two distinct types of drag-and-drop gestures:
/// 1. [INTRA-COLUMN REORDERING]: Handled by [ReorderableListView] (simple drag).
/// 2. [INTER-COLUMN MOVEMENT]: Handled by [DragTarget] and [LongPressDraggable] (long press).
class BoardColumnWidget extends ConsumerWidget {
  final BoardColumn column;

  const BoardColumnWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the cards for this specific column. 
    // Riverpod's 'family' modifier ensures we get the list for column.id.
    final cardsAsync = ref.watch(cardNotifierProvider(column.id));

    return DragTarget<CardItem>(
      /// Defines which data this column can receive.
      /// 
      /// INTER-COLUMN LOGIC: We only accept cards if they are coming from 
      /// a column with a different ID than this one.
      onWillAcceptWithDetails: (details) => details.data.columnId != column.id,

      /// Triggered when a card from another column is dropped here.
      onAcceptWithDetails: (details) async {
        final draggedCard = details.data;
        
        // 1. Create a clone of the card but with THIS column's ID.
        final updatedCard = draggedCard.copyWith(columnId: column.id);

        // 2. OPTIMISTIC UI: Immediately add the card to the target column's state 
        // so the user sees the movement without waiting for the network/database.
        ref.read(cardNotifierProvider(column.id).notifier).addCardLocally(updatedCard);

        // 3. PERSISTENCE: Tell the source column's Notifier to update the card in the database.
        // This will also trigger the removal of the card from the source list.
        await ref
            .read(cardNotifierProvider(draggedCard.columnId).notifier)
            .updateCard(updatedCard);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            // Visual feedback: Highlight the column when a valid card is hovering over it.
            color: candidateData.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Column Title
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
                    
                    /// INTRA-COLUMN REORDERING
                    /// ReorderableListView allows users to sort cards by dragging them up or down.
                    return ReorderableListView.builder(
                      // Fires when a card is moved within this column.
                      onReorder: (oldIndex, newIndex) {
                        ref.read(cardNotifierProvider(column.id).notifier)
                            .reorderCards(oldIndex, newIndex);
                      },
                      itemCount: cards.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),

                      itemBuilder: (context, index) {
                        final card = cards[index];

                        /// INTER-COLUMN MOVEMENT
                        /// We use LongPressDraggable to avoid conflict with the 
                        /// simple drag gesture of ReorderableListView.
                        return LongPressDraggable<CardItem>(
                          // Each child of ReorderableListView must have a unique Key.
                          key: ValueKey(card.id), 
                          data: card, // The card object that will be passed to DragTarget.

                          // The visual "ghost" that follows the finger during the drag.
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),

                          // The placeholder that stays in the column while dragging.
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _CardItem(card: card),
                          ),

                          // The standard appearance of the card.
                          child: _CardItem(card: card),
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

/// A simple presentational widget for the card's UI.
class _CardItem extends StatelessWidget {
  final CardItem card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}