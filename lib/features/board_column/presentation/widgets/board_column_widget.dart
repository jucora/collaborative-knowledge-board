import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../card/domain/entities/card_item.dart';
import '../../../card/presentation/providers/card_notifier_provider.dart';
import '../../domain/entities/board_column.dart';

/// A widget that represents a single column in the board.
/// It acts as a [DragTarget] to receive cards from other columns.
class BoardColumnWidget extends ConsumerWidget {
  final BoardColumn column;

  const BoardColumnWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardNotifierProvider(column.id));

    return DragTarget<CardItem>(
      /// Determines if the column should accept the dragged card.
      /// Only accepts if the card is coming from a different column.
      onWillAcceptWithDetails: (details) => details.data.columnId != column.id,

      /// Handles the logic when a card is dropped onto this column.
      onAcceptWithDetails: (details) async {
        final draggedCard = details.data;

        // 1. Create a copy of the card with the new column ID.
        final updatedCard = draggedCard.copyWith(columnId: column.id);

        // 2. Optimistic Update: Add the card to the target column locally for instant feedback.
        ref.read(cardNotifierProvider(column.id).notifier).addCardLocally(updatedCard);

        // 3. Update the backend/source: This will remove the card from the source column's list.
        await ref
            .read(cardNotifierProvider(draggedCard.columnId).notifier)
            .updateCard(updatedCard);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            // Change background color when a card is being hovered over this column.
            color: candidateData.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(column.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Container(
                  width: double.infinity, // Ensures the whole column area is a drop zone.
                  child: cardsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => const Center(child: Text('Error')),
                    data: (cards) => ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];

                            /// Wraps the card in a [Draggable] widget.
                            return Draggable<CardItem>(
                              data: card,
                              axis: null, // Allow movement in any direction.
                              
                              // What is shown while dragging.
                              feedback: Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 280,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue),
                                  ),
                                  child: Text(card.title,
                                      style: const TextStyle(
                                          decoration: TextDecoration.none,
                                          color: Colors.black,
                                          fontSize: 14)),
                                ),
                              ),
                              
                              // What remains in the original position while dragging.
                              childWhenDragging: Opacity(
                                  opacity: 0.2,
                                  child: _CardItem(card: card)
                              ),
                              
                              // The normal widget when not being dragged.
                              child: _CardItem(card: card),
                            );
                          },
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Private widget for rendering a single card's appearance.
class _CardItem extends StatelessWidget {
  final CardItem card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(card.title),
      ),
    );
  }
}