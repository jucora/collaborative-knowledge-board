class Comment {
  final String id;
  final String cardId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentId; // For threaded comments (replies)
  final List<String> mentionedUserIds; // To handle mentions scalably

  const Comment({
    required this.id,
    required this.cardId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.parentId,
    this.mentionedUserIds = const [],
  });

  bool get isEdited => updatedAt != null;

  Comment copyWith({
    String? id,
    String? cardId,
    String? authorId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    List<String>? mentionedUserIds,
  }) {
    return Comment(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
    );
  }
}
