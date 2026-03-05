import '../../../card/domain/entities/card_item.dart';
import '../../domain/entities/board_column.dart';

class BoardColumnModel {
  final String id;
  final String boardId;
  final String title;
  final int position;
  final List<CardItem> cards;

  BoardColumnModel({
    required this.id,
    required this.boardId,
    required this.title,
    required this.position,
    required this.cards,
  });

  factory BoardColumnModel.fromJson(Map<String, dynamic> json) {
    return BoardColumnModel(
      id: json['id'],
      boardId: json['boardId'],
      title: json['title'],
      position: json['position'],
      cards: json['cards'],
    );
  }

  BoardColumn toEntity() {
    return BoardColumn(
      id: id,
      boardId: boardId,
      title: title,
      position: position,
      cards: cards,
    );
  }
}