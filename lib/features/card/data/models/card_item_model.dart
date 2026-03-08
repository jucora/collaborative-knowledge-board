import '../../domain/entities/card_item.dart';

class CardItemModel {
  final String id;
  final String columnId;
  final String title;
  final String description;
  final int position;
  final String createdBy;
  final DateTime createdAt;

  CardItemModel({
    required this.id,
    required this.columnId,
    required this.title,
    required this.description,
    required this.position,
    required this.createdBy,
    required this.createdAt,
  });

  /// JSON -> Model
  factory CardItemModel.fromJson(Map<String, dynamic> json) {
    return CardItemModel(
      id: json['id'],
      columnId: json['columnId'],
      title: json['title'],
      description: json['description'],
      position: json['position'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Model -> Entity
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

  /// Entity -> Model
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