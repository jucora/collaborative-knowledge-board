import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/common/error_retry_widget.dart';
import '../../../../core/widgets/common/skeleton_loader.dart';
import '../../../../core/widgets/common/theme_toggle_button.dart';
import '../../../../core/widgets/real_time_simulator_panel.dart';
import '../../../board_column/presentation/providers/board_column_notifier.dart';
import '../../../board_column/presentation/widgets/board_column_widget.dart';
import '../../../board_member/presentation/providers/board_member_usecase_provider.dart';

class BoardDetailPage extends ConsumerWidget {
  final String boardId;

  const BoardDetailPage({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardColumnsAsync = ref.watch(boardColumnNotifierProvider(boardId));

    const showSimulator = bool.fromEnvironment('SHOW_SIMULATOR', defaultValue: false);
    final canShowSimulator = showSimulator && !kReleaseMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _showShareBoardDialog(context, ref),
            tooltip: "Share Board",
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddColumnDialog(context, ref),
            tooltip: "Add Column",
          ),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
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

  void _showShareBoardDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Share Board"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter the email of the user you want to share this board with."),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "User Email",
                hintText: "user@example.com",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  // In a real scenario, you'd find the user ID by email first.
                  // For now, we'll try to find the user in our public.users table.
                  final supabase = Supabase.instance.client;
                  final userData = await supabase
                      .from('users')
                      .select('id')
                      .eq('email', email)
                      .maybeSingle();

                  if (userData == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User not found.")),
                      );
                    }
                    return;
                  }

                  final targetUserId = userData['id'] as String;

                  await ref.read(addBoardMemberUseCaseProvider).call(
                    boardId: boardId,
                    userId: targetUserId,
                    role: 'member',
                    joinedAt: DateTime.now(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Board shared successfully!")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error sharing board: $e")),
                    );
                  }
                }
              }
            },
            child: const Text("Share"),
          ),
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
