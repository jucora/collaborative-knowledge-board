class BoardMember {
  final String userId;
  final String boardId;
  final String role;
  final DateTime joinedAt;

  const BoardMember({
    required this.userId,
    required this.boardId,
    required this.role,
    required this.joinedAt,
  });

  BoardMember copyWith({
    String? userId,
    String? boardId,
    String? role,
    DateTime? joinedAt,
  }) {
    return BoardMember(
      userId: userId ?? this.userId,
      boardId: boardId ?? this.boardId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
