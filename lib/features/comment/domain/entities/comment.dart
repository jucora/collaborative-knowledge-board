class Comment {
  final String id;
  final String cardId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.cardId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    String? cardId,
    String? authorId,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}