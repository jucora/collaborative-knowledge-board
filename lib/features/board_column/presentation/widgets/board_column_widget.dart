import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../card/presentation/providers/cards_future_provider.dart';
import '../../../card/presentation/widgets/create_card_dialog.dart';
import '../../domain/entities/board_column.dart';

class BoardColumnWidget extends ConsumerWidget {

  final BoardColumn column;

  const BoardColumnWidget({
    super.key,
    required this.column,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final cardsAsync = ref.watch(cardsProvider(column.id));

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),

      child: Column(
        children: [

          Text(
            column.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: cardsAsync.when(

              loading: () =>
              const Center(child: CircularProgressIndicator()),

              error: (err, _) =>
                  Center(child: Text(err.toString())),

              data: (cards) {

                return ListView.builder(
                  itemCount: cards.length,
                  itemBuilder: (_, index) {

                    final card = cards[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(card.title),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          /// ADD CARD BUTTON
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => CreateCardDialog(
                  columnId: column.id,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Add card"),
          ),
        ],
      ),
    );
  }
}