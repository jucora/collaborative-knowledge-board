import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/common/error_retry_widget.dart';
import '../../../../core/widgets/common/skeleton_loader.dart';
import '../../../../core/widgets/real_time_simulator_panel.dart';
import '../../../board_column/presentation/providers/board_column_notifier.dart';
import '../../../board_column/presentation/widgets/board_column_widget.dart';

class BoardDetailPage extends ConsumerWidget {
  final String boardId;

  const BoardDetailPage({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Migrated from FutureProvider to NotifierProvider for action support
    final boardColumnsAsync = ref.watch(boardColumnNotifierProvider(boardId));
    final themeMode = ref.watch(themeProvider);

    const showSimulator = bool.fromEnvironment('SHOW_SIMULATOR', defaultValue: false);
    final canShowSimulator = showSimulator && !kReleaseMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded), // Fixed: used a standard icon
            onPressed: () => _showAddColumnDialog(context, ref),
            tooltip: "Add Column",
          ),
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
              onRetry: () => ref.invalidate(boardColumnNotifierProvider(boardId)),
            ),
            data: (columns) {
              if (columns.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No columns yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddColumnDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text("Create First Column"),
                      )
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...columns.map((column) => BoardColumnWidget(column: column)),
                            // Shortcut to add column at the end
                            _buildAddColumnButton(context, ref),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          
          if (canShowSimulator)
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

  void _showAddColumnDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Column"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Column title (e.g. To Do, In Progress)",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(boardColumnNotifierProvider(boardId).notifier).createColumn(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddColumnButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: OutlinedButton.icon(
        onPressed: () => _showAddColumnDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text("Add another column"),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            style: BorderStyle.solid,
          ),
        ),
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
