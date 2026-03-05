import 'package:flutter/material.dart';

/// Página de detalle de un board.
/// Recibe el boardId desde el router.
///
/// Esta página está preparada para:
/// - Mostrar columnas en horizontal
/// - Mostrar cards en vertical dentro de cada columna
class BoardDetailPage extends StatelessWidget {
  final String boardId;

  const BoardDetailPage({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Board: $boardId'),
      ),
      body: const _BoardColumnsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí en el siguiente nivel
          // abriremos modal para crear columna
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BoardColumnsView extends StatelessWidget {
  const _BoardColumnsView();

  @override
  Widget build(BuildContext context) {
    // Mock temporal hasta implementar Column feature
    final mockColumns = [
      'Todo',
      'In Progress',
      'Done',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: mockColumns
            .map(
              (column) => Padding(
            padding: const EdgeInsets.all(8),
            child: _ColumnWidget(title: column),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _ColumnWidget extends StatelessWidget {
  final String title;

  const _ColumnWidget({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Mock cards
    final mockCards = [
      'Task 1',
      'Task 2',
      'Task 3',
    ];

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: mockCards.length,
              itemBuilder: (_, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(mockCards[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}