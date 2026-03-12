import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/real_time_simulator_panel.dart';
import '../../../board_column/presentation/providers/board_column_future_provider.dart';
import '../../../board_column/presentation/widgets/board_column_widget.dart';

/// Board detail page optimized for performance.
/// 
/// PERFORMANCE OPTIMIZATION:
/// 1. Uses [ListView.builder] for horizontal scrolling of columns to ensure 
///    lazy loading and memory efficiency with many columns.
/// 2. Uses [const] widgets where possible.
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

              // PERFORMANCE: ListView.builder is used for horizontal scrolling 
              // instead of Row + SingleChildScrollView to enable virtualization.
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: columns.length,
                cacheExtent: 1000, // Pre-renders some columns for smoother scrolling
                itemBuilder: (context, index) {
                  return BoardColumnWidget(column: columns[index]);
                },
              );
            },
          ),
          
          // REAL-TIME SIMULATOR PANEL
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
