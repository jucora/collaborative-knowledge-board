import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.cardId,
    required super.authorId,
    required super.content,
    required super.createdAt,
    super.updatedAt,
    super.parentId,
    super.mentionedUserIds = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      parentId: json['parent_id'] as String?,
      mentionedUserIds: (json['mentioned_user_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'parent_id': parentId,
      'mentioned_user_ids': mentionedUserIds,
    };
  }

  Comment toEntity() {
    return Comment(
      id: id,
      cardId: cardId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parentId: parentId,
      mentionedUserIds: mentionedUserIds,
    );
  }

  factory CommentModel.fromEntity(Comment entity) {
    return CommentModel(
      id: entity.id,
      cardId: entity.cardId,
      authorId: entity.authorId,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      parentId: entity.parentId,
      mentionedUserIds: entity.mentionedUserIds,
    );
  }
}
