import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../data/repositories/fake_board_repository_impl.dart';
import '../../domain/entities/board.dart';
import '../providers/board_notifier.dart';

final boardNotifierProvider =
AsyncNotifierProvider<BoardNotifier, List<Board>>(
      () {
    final repository = FakeBoardRepositoryImpl();

    return BoardNotifier(repository);
  },
);

class BoardDashboardPage extends ConsumerWidget {
  const BoardDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardsAsync = ref.watch(boardNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Boards')),
      body: boardsAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            error is Failure
                ? error.message
                : 'Unexpected error',
          ),
        ),
        data: (boards) {
          if (boards.isEmpty) {
            return const Center(
              child: Text('No boards yet'),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(boardNotifierProvider.notifier)
                    .refreshBoards(),
            child: ListView.builder(
              itemCount: boards.length,
              itemBuilder: (_, index) {
                final board = boards[index];
                return ListTile(
                  title: Text(board.title),
                  subtitle: Text(board.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref
                          .read(boardNotifierProvider.notifier)
                          .deleteBoard(board.id);
                    },
                  ),
                  onTap: () {
                    context.go('/boards/${board.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}