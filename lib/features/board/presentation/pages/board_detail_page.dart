import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/real_time_simulator_panel.dart';
import '../../../board_column/presentation/providers/board_column_future_provider.dart';
import '../../../board_column/presentation/widgets/board_column_widget.dart';

/// Página de detalle de un board.
class BoardDetailPage extends ConsumerWidget {
  final String boardId;

  const BoardDetailPage({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardColumnsAsync = ref.watch(
      boardColumnsProvider(boardId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Board Detail')),
      body: Stack(
        children: [
          boardColumnsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (columns) {
              if (columns.isEmpty) {
                return const Center(child: Text('No columns yet'));
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: columns
                      .map((column) => BoardColumnWidget(column: column))
                      .toList(),
                ),
              );
            },
          ),
          
          // REAL-TIME SIMULATOR PANEL
          // This panel allows you to simulate external events and connection loss.
          boardColumnsAsync.whenData((columns) {
            if (columns.isEmpty) return const SizedBox.shrink();
            return RealTimeSimulatorPanel(
              currentBoardId: boardId,
              firstColumnId: columns.first.id,
            );
          }).value ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}