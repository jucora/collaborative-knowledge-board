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
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      ownerId: json['owner_id'] as String,
      columns: (json['columns'] as List<dynamic>?)
              ?.map((e) => BoardColumnModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      members: (json['members'] as List<dynamic>?)
              ?.map((e) {
                final userData = e['user'] as Map<String, dynamic>?;
                if (userData != null) {
                  return UserModel.fromJson(userData);
                }
                // Si viene de board_members directamente sin join
                return UserModel(
                  id: e['user_id'] ?? '',
                  name: 'Member',
                  email: '',
                  createdAt: DateTime.now(),
                );
              })
              .toList() ??
          const [],
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
      members: entity.members.map((e) => UserModel.fromEntity(e)).toList(),
    );
  }
}
