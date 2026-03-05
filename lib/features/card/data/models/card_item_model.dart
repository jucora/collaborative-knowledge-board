import '../../domain/entities/card_item.dart';
import '../../../comment/data/models/comment_model.dart';

class CardItemModel {
  final String id;
  final String columnId;
  final String title;
  final String description;
  final int position;
  final String createdBy;
  final DateTime createdAt;
  final List<CommentModel> comments;

  CardItemModel({
    required this.id,
    required this.columnId,
    required this.title,
    required this.description,
    required this.position,
    required this.createdBy,
    required this.createdAt,
    required this.comments,
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
      comments: (json['comments'] as List)
          .map((e) => CommentModel.fromJson(e))
          .toList(),
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
      comments: comments.map((e) => e.toEntity()).toList(),
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
      comments: entity.comments
          .map((e) => CommentModel.fromEntity(e))
          .toList(),
    );
  }
}