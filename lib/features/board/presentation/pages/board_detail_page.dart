import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/common/error_retry_widget.dart';
import '../../../../core/widgets/common/skeleton_loader.dart';
import '../../../../core/widgets/real_time_simulator_panel.dart';
import '../../../board_column/presentation/providers/board_column_future_provider.dart';
import '../../../board_column/presentation/widgets/board_column_widget.dart';

class BoardDetailPage extends ConsumerWidget {
  final String boardId;

  const BoardDetailPage({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardColumnsAsync = ref.watch(boardColumnsProvider(boardId));
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Detail'),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: "Toggle Dark/Light Mode",
          ),
        ],
      ),
      body: Stack(
        children: [
          boardColumnsAsync.when(
            loading: () => _buildSkeletonLoader(),
            error: (error, _) => ErrorRetryWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(boardColumnsProvider(boardId)),
            ),
            data: (columns) {
              if (columns.isEmpty) {
                return const Center(child: Text('No columns yet'));
              }

              // DISTRIBUTED & CENTERED LAYOUT
              // We use LayoutBuilder and ConstrainedBox to ensure the Row takes at least the full screen width,
              // allowing spaceEvenly to distribute columns equitably.
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: columns
                              .map((column) => BoardColumnWidget(column: column))
                              .toList(),
                        ),
                      ),
                    ),
                  );
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

  Widget _buildSkeletonLoader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) => Container(
                width: 300,
                margin: const EdgeInsets.all(16),
                child: const Column(
                  children: [
                    SkeletonLoader(height: 40, borderRadius: 12),
                    SizedBox(height: 16),
                    SkeletonLoader(height: 100, borderRadius: 12),
                    SizedBox(height: 16),
                    SkeletonLoader(height: 100, borderRadius: 12),
                  ],
                ),
              )),
            ),
          ),
        );
      },
    );
  }
}
