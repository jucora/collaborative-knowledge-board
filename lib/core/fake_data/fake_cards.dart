import '../../features/board_column/domain/entities/board_column.dart';
import '../../features/card/domain/entities/card_item.dart';
import 'fake_users.dart';

class FakeCards {
  static List<CardItem> generate({
    required List<BoardColumn> columns,
  }) {
    final cards = <CardItem>[];

    for (final column in columns) {
      for (int i = 0; i < 5; i++) {
        cards.add(
          CardItem(
            id: '${column.id}_card_$i',
            columnId: column.id,
            title: faker.lorem.sentence(),
            description: faker.lorem.sentence(),
            position: i,
            createdBy: 'user_${i % 3}', // Simula 3 usuarios diferentes
            createdAt: DateTime.now().subtract(Duration(days: i),),
            comments: [],
        ));
      }
    }

    return cards;
  }
}