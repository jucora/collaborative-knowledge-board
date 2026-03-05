import '../../features/board/domain/entities/board.dart';
import '../../features/board_column/domain/entities/board_column.dart';

class FakeColumns {
  static List<BoardColumn> generate({
    required List<Board> boards,
  }) {
    final columns = <BoardColumn>[];

    for (final board in boards) {
      final titles = ['Todo', 'In Progress', 'Review', 'Done'];

      for (int i = 0; i < titles.length; i++) {
        columns.add(
          BoardColumn(
            id: '${board.id}_column_$i',
            boardId: board.id,
            title: titles[i],
            position: i,
            cards: [], // Aquí podrías generar tarjetas falsas si lo deseas
          ),
        );
      }
    }

    return columns;
  }
}