import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/board_future_provider.dart';

class BoardDashboardPage extends ConsumerWidget {
  const BoardDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final boardsAsync = ref.watch(boardNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boards'),
      ),
      body: boardsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text(error.toString()),
        ),
        data: (boards) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: boards.length,
            itemBuilder: (context, index) {
              final board = boards[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      context.go('/boards/${board.id}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.dashboard,
                            size: 28,
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Text(
                              board.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}