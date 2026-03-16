import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/common/theme_toggle_button.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/entities/board.dart';
import '../providers/board_notifier.dart';

class BoardDashboardPage extends ConsumerWidget {
  const BoardDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardsAsync = ref.watch(boardNotifierProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workspace'),
          actions: [
            const ThemeToggleButton(),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _showLogoutDialog(context, ref),
              tooltip: "Logout",
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "My Boards", icon: Icon(Icons.person_rounded)),
              Tab(text: "Shared with Me", icon: Icon(Icons.group_rounded)),
            ],
          ),
        ),
        body: boardsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (boards) {
            // board filter
            final myBoards = boards.where((b) => b.ownerId == currentUserId).toList();
            final sharedBoards = boards.where((b) => b.ownerId != currentUserId).toList();

            return TabBarView(
              children: [
                _BoardList(
                  boards: myBoards,
                  emptyMessage: "You haven't created any boards yet.",
                  onAction: () => _showCreateBoardDialog(context, ref),
                ),
                _BoardList(
                  boards: sharedBoards,
                  emptyMessage: "No boards have been shared with you yet.",
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateBoardDialog(context, ref),
          label: const Text("New Board"),
          icon: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New Board"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Board Title"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await ref.read(boardNotifierProvider.notifier).createBoard(
                      title: titleController.text,
                      description: descController.text,
                    );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _BoardList extends StatelessWidget {
  final List<Board> boards;
  final String emptyMessage;
  final VoidCallback? onAction;

  const _BoardList({
    required this.boards,
    required this.emptyMessage,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (boards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard_customize_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade600)),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: const Text("Create your first board"),
              ),
            ]
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return _BoardCard(board: board);
      },
    );
  }
}

class _BoardCard extends StatelessWidget {
  final Board board;
  const _BoardCard({required this.board});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go('/boards/${board.id}'),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        board.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        board.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
