import '../../../card/domain/entities/card_item.dart';

class BoardColumn {
  final String id;
  final String boardId;
  final String title;
  final int position;
  final List<CardItem> cards;

  const BoardColumn({
    required this.id,
    required this.boardId,
    required this.title,
    required this.position,
    required this.cards,
  });

  BoardColumn copyWith({
    String? id,
    String? boardId,
    String? title,
    int? position,
    List<CardItem>? cards,
  }) {
    return BoardColumn(
      id: this.id,
      boardId: this.boardId,
      title: this.title,
      position: this.position,
      cards: this.cards,
    );
  }
}