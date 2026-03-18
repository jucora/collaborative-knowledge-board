import '../../domain/entities/board_column.dart';
import '../../../card/data/models/card_item_model.dart';

class BoardColumnModel extends BoardColumn {
  const BoardColumnModel({
    required super.id,
    required super.boardId,
    required super.title,
    required super.position,
    required super.cards,
  });

  factory BoardColumnModel.fromJson(Map<String, dynamic> json) {
    return BoardColumnModel(
      id: json['id'] as String,
      boardId: json['boardId'] as String,
      title: json['title'] as String,
      position: json['position'] as int,
      cards: (json['cards'] as List<dynamic>)
          .map((e) => CardItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boardId': boardId,
      'title': title,
      'position': position,
      'cards': cards
          .map((e) => CardItemModel.fromEntity(e).toJson())
          .toList(),
    };
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

  factory BoardColumnModel.fromEntity(BoardColumn entity) {
    return BoardColumnModel(
      id: entity.id,
      boardId: entity.boardId,
      title: entity.title,
      position: entity.position,
      // FIX: Ensure all cards are converted to CardItemModel to avoid TypeErrors in the UI
      cards: entity.cards.map((c) => CardItemModel.fromEntity(c)).toList(),
    );
  }
}
