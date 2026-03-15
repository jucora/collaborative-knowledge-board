import '../../domain/entities/board.dart';
import '../../../board_column/data/models/board_column_model.dart';
import '../../../user/models/user_model.dart';

class BoardModel extends Board {
  const BoardModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.ownerId,
    required super.columns,
    required super.members,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      ownerId: json['owner_id'] as String,
      columns: (json['columns'] as List<dynamic>)
          .map((e) => BoardColumnModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'owner_id': ownerId,
      'columns': columns
          .map((e) => BoardColumnModel.fromEntity(e).toJson())
          .toList(),
      'members': members
          .map((e) => UserModel.fromEntity(e).toJson())
          .toList(),
    };
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

  factory BoardModel.fromEntity(Board entity) {
    return BoardModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      ownerId: entity.ownerId,
      columns: entity.columns,
      members: entity.members,
    );
  }
}
