import 'package:collaborative_knowledge_board/features/card/domain/entities/card_item.dart';
import '../../../../core/fake_data/fake_database.dart';
import '../../../comment/domain/entities/comment.dart';

class FakeCardDatasource {

  final FakeDatabase database;

  FakeCardDatasource(this.database);

  Future<List<CardItem>> getCardsByColumn(String columnId) async {

    await Future.delayed(const Duration(milliseconds: 200));

    return database.cards
        .where((c) => c.columnId == columnId)
        .toList();
  }

  Future<void> createCard(CardItem card) async {
    database.cards.add(card);
  }
}