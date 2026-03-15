import '../../domain/entities/card_item.dart';

class CardItemModel extends CardItem {
  const CardItemModel({
    required super.id,
    required super.columnId,
    required super.title,
    required super.description,
    required super.position,
    required super.createdBy,
    required super.createdAt,
  });

  factory CardItemModel.fromJson(Map<String, dynamic> json) {
    return CardItemModel(
      id: json['id'] as String,
      columnId: json['columnId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      position: json['position'] as int,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'columnId': columnId,
      'title': title,
      'description': description,
      'position': position,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CardItem toEntity() {
    return CardItem(
      id: id,
      columnId: columnId,
      title: title,
      description: description,
      position: position,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  factory CardItemModel.fromEntity(CardItem entity) {
    return CardItemModel(
      id: entity.id,
      columnId: entity.columnId,
      title: entity.title,
      description: entity.description,
      position: entity.position,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }
}
