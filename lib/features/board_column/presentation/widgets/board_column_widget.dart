import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/sync_service.dart';
import '../../../card/domain/entities/card_item.dart';
import '../../../card/presentation/providers/card_notifier_provider.dart';
import '../../../card/presentation/widgets/card_detail_dialog.dart';
import '../../domain/entities/board_column.dart';

class BoardColumnWidget extends ConsumerWidget {
  final BoardColumn column;

  const BoardColumnWidget({super.key, required this.column});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardNotifierProvider(column.id));
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = screenWidth < 600 ? screenWidth * 0.85 : 300.0;
    
    const double estimatedCardHeight = 85.0; 

    return DragTarget<CardItem>(
      onWillAcceptWithDetails: (details) => true,
      
      onMove: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.offset);
        final cardsAreaY = localPosition.dy - 65; 
        
        if (cardsAreaY > -estimatedCardHeight) {
          ref.read(cardNotifierProvider(column.id).notifier)
             .updatePreview(details.data, cardsAreaY, estimatedCardHeight);
        }
      },

      onLeave: (data) {
        if (data != null) {
          ref.read(cardNotifierProvider(column.id).notifier).removePreview(data.id);
        }
      },

      onAcceptWithDetails: (details) async {
        final draggedCard = details.data;
        final currentCards = ref.read(cardNotifierProvider(column.id)).value ?? [];
        
        for (int i = 0; i < currentCards.length; i++) {
          final card = currentCards[i];
          if (card.id == draggedCard.id || card.position != i) {
            final updatedCard = card.copyWith(columnId: column.id, position: i);
            await ref.read(cardNotifierProvider(draggedCard.columnId).notifier).updateCard(updatedCard);
          }
        }
        
        if (draggedCard.columnId != column.id) {
          ref.invalidate(cardNotifierProvider(draggedCard.columnId));
        }
        
        ref.read(cardNotifierProvider(column.id).notifier).removePreview(draggedCard.id);
      },
      builder: (context, candidateData, rejectedData) {
        final theme = Theme.of(context);
        return Container(
          width: columnWidth,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? theme.colorScheme.primary.withOpacity(0.05) 
                : theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.list_alt_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        column.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    return ListView.builder(
                      itemCount: cards.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        final isGhost = candidateData.isNotEmpty && 
                                        candidateData.any((c) => c?.id == card.id);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          key: ValueKey(card.id),
                          child: isGhost 
                            ? _GhostCard(width: columnWidth - 20)
                            : _DraggableCardWrapper(
                                card: card,
                                width: columnWidth - 20,
                              ),
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

class _GhostCard extends StatelessWidget {
  final double width;
  const _GhostCard({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 75,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
    );
  }
}

class _DraggableCardWrapper extends StatelessWidget {
  final CardItem card;
  final double width;
  const _DraggableCardWrapper({super.key, required this.card, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return LongPressDraggable<CardItem>(
      data: card,
      feedback: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primary, width: 2),
          ),
          child: Text(
            card.title,
            style: TextStyle(
              fontSize: 14, 
              color: isDarkMode ? Colors.white : Colors.black, 
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      childWhenDragging: const SizedBox.shrink(),
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

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0.5,
      color: isPending 
          ? (isDarkMode ? Colors.amber.shade900.withOpacity(0.3) : Colors.amber.shade50)
          : null, 
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                card.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 15,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isPending)
              const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
