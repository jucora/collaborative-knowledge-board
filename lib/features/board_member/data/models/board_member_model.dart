import '../../domain/entities/board_member.dart';

class BoardMemberModel extends BoardMember {
  const BoardMemberModel({
    required super.userId,
    required super.boardId,
    required super.role,
    required super.joinedAt,
  });

  factory BoardMemberModel.fromJson(Map<String, dynamic> json) {
    return BoardMemberModel(
      userId: json['user_id'] as String,
      boardId: json['board_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'board_id': boardId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  BoardMember toEntity() {
    return BoardMember(
      userId: userId,
      boardId: boardId,
      role: role,
      joinedAt: joinedAt,
    );
  }

  factory BoardMemberModel.fromEntity(BoardMember entity) {
    return BoardMemberModel(
      userId: entity.userId,
      boardId: entity.boardId,
      role: entity.role,
      joinedAt: entity.joinedAt,
    );
  }
}
