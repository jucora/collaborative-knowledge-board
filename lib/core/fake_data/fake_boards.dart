import 'package:collaborative_knowledge_board/features/user/entities/user.dart';
import '../../features/board/domain/entities/board.dart';
import 'fake_users.dart';

class FakeBoards {
  static List<Board> generate({
    required List<User> boardMembers,
    int count = 3,
  }) {
    return List.generate(count, (index) {
      return Board(
        id: 'board_$index',
        title: faker.company.name(),
        description: faker.lorem.sentence(),
        createdAt: DateTime.now().subtract(Duration(days: index * 2)),
        ownerId: boardMembers.first.id,
        columns: [], // Puedes generar columnas de manera similar si lo deseas
        members: boardMembers, // Todos los usuarios son miembros para simplificar
      );
    });
  }
}