import '../repositories/board_member_repository.dart';

class AddBoardMemberUseCase {
  final BoardMemberRepository repository;

  AddBoardMemberUseCase(this.repository);

  Future<void> call ({
    required userId,
    required String boardId,
    required String role,
    required DateTime joinedAt,
  }) {
    return repository.addMemberToBoard(
      userId: userId,
      boardId: boardId,
      role: role,
      joinedAt: joinedAt,
    );
  }
}