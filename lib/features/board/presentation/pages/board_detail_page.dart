import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../board_column/presentation/providers/fake_board_column_providers.dart';
import '../../../board_column/presentation/widgets/board_column_widget.dart';

/// Página de detalle de un board.
///
/// Recibe el boardId desde el router.
///
/// Responsabilidades:
/// - Obtener columnas del board
/// - Renderizar columnas horizontalmente
/// - Delegar la renderización de cards al BoardColumnWidget
class BoardDetailPage extends ConsumerWidget {
  final String boardId;

  const BoardDetailPage({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    /// Observamos las columnas del board
    final columnsAsync = ref.watch(boardColumnsProvider(boardId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Board: $boardId'),
      ),

      body: columnsAsync.when(

        /// Estado loading
        loading: () =>
        const Center(child: CircularProgressIndicator()),

        /// Estado error
        error: (err, _) =>
            Center(child: Text(err.toString())),

        /// Estado data
        data: (columns) {

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: columns
                  .map(
                    (column) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: BoardColumnWidget(column: column),
                ),
              )
                  .toList(),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /// En el siguiente paso aquí abriremos
          /// el modal para crear columnas
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}