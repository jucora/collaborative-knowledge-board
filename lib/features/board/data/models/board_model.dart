import 'package:collaborative_knowledge_board/features/user/entities/user.dart';
import '../../../board_column/domain/entities/board_column.dart';
import '../../domain/entities/board.dart';

class BoardModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String ownerId;
  final List<BoardColumn> columns;
  final List<User> members;

  BoardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.ownerId,
    required this.columns,
    required this.members,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'],
      ownerId: json['owner_id'],
      columns: json['columns'],
      members: json['members']
    );
  }

  Board toEntity() {
    return Board(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      ownerId: ownerId,
      columns: columns,
      members: members,
    );
  }
}