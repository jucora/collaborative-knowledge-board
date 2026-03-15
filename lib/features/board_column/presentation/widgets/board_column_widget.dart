import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/sync_service.dart';
import '../../../card/domain/entities/card_item.dart';
import '../../../card/presentation/providers/card_notifier_provider.dart';
import '../../../card/presentation/widgets/card_detail_dialog.dart';
import '../../../card/presentation/widgets/create_card_dialog.dart';
import '../../domain/entities/board_column.dart';

class BoardColumnWidget extends ConsumerStatefulWidget {
  final BoardColumn column;

  const BoardColumnWidget({super.key, required this.column});

  @override
  ConsumerState<BoardColumnWidget> createState() => _BoardColumnWidgetState();
}

class _BoardColumnWidgetState extends ConsumerState<BoardColumnWidget> {
  late final ScrollController _scrollController;
  static const double _cardHeight = 80.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(cardNotifierProvider(widget.column.id));
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = screenWidth < 600 ? screenWidth * 0.85 : 300.0;

    return DragTarget<CardItem>(
      onWillAcceptWithDetails: (details) => true,
      onMove: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPosition = renderBox.globalToLocal(details.offset);
        
        double scrollOffset = 0;
        if (_scrollController.hasClients) {
          scrollOffset = _scrollController.offset;
        }

        // We use a small vertical offset (-20) to make it easier to reach the top/bottom slots.
        final cardsAreaY = localPosition.dy - 60 + scrollOffset; 
        
        ref.read(cardNotifierProvider(widget.column.id).notifier)
           .updatePreview(details.data, cardsAreaY, _cardHeight + 12); 
      },
      onLeave: (data) {
        if (data != null) {
          ref.read(cardNotifierProvider(widget.column.id).notifier).removePreview(data.id);
        }
      },
      onAcceptWithDetails: (details) async {
        final draggedCard = details.data;
        
        // When a card is accepted, it is already "physically" in the correct position 
        // in the CardNotifier's state due to the preview logic.
        // We just need to trigger the actual update to persist this position.
        
        final currentCards = ref.read(cardNotifierProvider(widget.column.id)).value ?? [];
        
        // Important: We iterate over currentCards to update ALL affected cards' positions.
        for (int i = 0; i < currentCards.length; i++) {
          final card = currentCards[i];
          // If it's the dragged card OR its position property doesn't match its index in the list
          if (card.id == draggedCard.id || card.position != i) {
            final updatedCard = card.copyWith(columnId: widget.column.id, position: i);
            
            // We call the updateCard of the ORIGIN column notifier because it's the one
            // responsible for the logic (even if it's moving between columns).
            // Actually, we should call the update on the notifier where the card is NOW.
            await ref.read(cardNotifierProvider(widget.column.id).notifier).updateCard(updatedCard);
          }
        }
        
        // If moving between columns, invalidate the source column to cleanup
        if (draggedCard.columnId != widget.column.id) {
          ref.invalidate(cardNotifierProvider(draggedCard.columnId));
        }
        
        // We DON'T removePreview here because updateCard already updated the state with the real card.
        // But for safety and to clear the internal notifier variables:
        ref.read(cardNotifierProvider(widget.column.id).notifier).removePreview(draggedCard.id);
      },
      builder: (context, candidateData, rejectedData) {
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
                        widget.column.title,
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
                      controller: _scrollController,
                      itemCount: cards.length + 2, 
                      padding: const EdgeInsets.only(bottom: 10),
                      itemBuilder: (context, index) {
                        if (index == cards.length + 1) return const SizedBox(height: 100); 

                        if (index == cards.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: OutlinedButton.icon(
                              onPressed: () => _showCreateCardDialog(context, widget.column.id),
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text("Add Card"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          );
                        }

                        final card = cards[index];
                        final isGhost = candidateData.isNotEmpty && candidateData.any((c) => c?.id == card.id);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          key: ValueKey(card.id),
                          child: isGhost 
                            ? _GhostCard(width: columnWidth - 20, height: _cardHeight)
                            : _DraggableCardWrapper(
                                card: card,
                                width: columnWidth - 20,
                                height: _cardHeight,
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

  void _showCreateCardDialog(BuildContext context, String columnId) {
    showDialog(context: context, builder: (context) => CreateCardDialog(columnId: columnId));
  }
}

class _GhostCard extends StatelessWidget {
  final double width;
  final double height;
  const _GhostCard({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
  final double height;
  const _DraggableCardWrapper({
    super.key, 
    required this.card, 
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return LongPressDraggable<CardItem>(
      data: card,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
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
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        child: _CardItem(card: card, height: height),
      ),
    );
  }
}

class _CardItem extends ConsumerWidget {
  final CardItem card;
  final double height;
  const _CardItem({required this.card, required this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = ref.watch(syncServiceProvider.select(
      (sync) => sync.pendingActions.any(
        (action) => (action.data is CardItem && (action.data as CardItem).id == card.id)
      )
    ));

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Card(
        elevation: 0.5,
        margin: EdgeInsets.zero,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isPending)
                const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.amber),
            ],
          ),
        ),
      ),
    );
  }
}
