import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/real_time_service.dart';
import '../fake_data/fake_database_provider.dart';
import '../../features/card/domain/entities/card_item.dart';

/// A floating panel to simulate real-time events and connection status.
class RealTimeSimulatorPanel extends ConsumerWidget {
  final String? currentBoardId;
  final String? firstColumnId;

  const RealTimeSimulatorPanel({
    super.key,
    this.currentBoardId,
    this.firstColumnId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realTimeService = ref.watch(realTimeServiceProvider);
    final isOnline = realTimeService.isConnected;

    return DraggableScrollableSheet(
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "REAL-TIME SIMULATOR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer
                    ),
                  ),
                ],
              ),
              const Divider(),
              
              SwitchListTile(
                title: const Text("Connection Status"),
                subtitle: Text(isOnline ? "Online - Events enabled" : "Offline - Events blocked"),
                value: isOnline,
                activeColor: Colors.green,
                onChanged: (value) {
                  ref.read(realTimeServiceProvider).setConnection(value);
                },
              ),
              
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                icon: const Icon(Icons.add_to_photos),
                label: const Text("Create External Card"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: isOnline && firstColumnId != null
                    ? () => _simulateExternalCard(ref)
                    : null,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "This adds a card to the DB and notifies all columns.",
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulateExternalCard(WidgetRef ref) {
    final db = ref.read(fakeDatabaseProvider);
    
    final simulatedCard = CardItem(
      id: 'ext-${DateTime.now().millisecondsSinceEpoch}',
      columnId: firstColumnId!,
      title: "External User Card 🚀",
      description: "Created via simulation at ${DateTime.now().hour}:${DateTime.now().minute}",
      position: db.cards.where((c) => c.columnId == firstColumnId).length,
      createdBy: "Remote User",
      createdAt: DateTime.now(),
    );

    // 1. Add to the shared database so it can be moved/updated later
    db.cards.add(simulatedCard);

    // 2. Notify the UI
    ref.read(realTimeServiceProvider).notify(
      RealTimeEventType.cardCreated,
      simulatedCard,
    );
  }
}