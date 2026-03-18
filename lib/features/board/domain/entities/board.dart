import 'package:collaborative_knowledge_board/features/user/entities/user.dart';

import '../../../board_column/domain/entities/board_column.dart';
import '../../../board_member/domain/entities/board_member.dart';

class Board {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String ownerId;
  final List<BoardColumn> columns;
  final List<User> members;

  const Board({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.ownerId,
    required this.columns,
    required this.members,
  });

  Board copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    String? ownerId,
    List<BoardColumn>? columns,
    List<BoardMember>? members,
  }) {
    return Board(
      id: this.id,
      title: this.title,
      description: this.description,
      createdAt: this.createdAt,
      ownerId: this.ownerId,
      columns: this.columns,
      members: this.members,
    );
  }
}