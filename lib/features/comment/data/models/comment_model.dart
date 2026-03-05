import '../../domain/entities/comment.dart';

class CommentModel {
  final String id;
  final String cardId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.cardId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      cardId: json['cardId'],
      authorId: json['author_id'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
    );
  }

  /// Entity -> Model
  factory CommentModel.fromEntity(Comment entity) {
    return CommentModel(
      id: entity.id,
      cardId: entity.cardId,
      authorId: entity.authorId,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }
}