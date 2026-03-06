class BoardMemberModel {
  final String userId;
  final String boardId;
  final String role;
  final DateTime joinedAt;

  BoardMemberModel({
    required this.userId,
    required this.boardId,
    required this.role,
    required this.joinedAt,
  });

  factory BoardMemberModel.fromJson(Map<String, dynamic> json) {
    return BoardMemberModel(
      userId: json['id'] as String,
      boardId: json['name'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'boardId': boardId,
      'role': role,
      'joinedAt': joinedAt,
    };
  }
}