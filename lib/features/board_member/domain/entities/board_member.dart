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
    String? joinedAt,
  }) {
    return BoardMember(
      userId: this.userId,
      boardId: this.boardId,
      role: this.role,
      joinedAt: this.joinedAt,
    );
  }
}