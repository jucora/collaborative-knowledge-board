import '../repositories/board_member_repository.dart';

class DeleteBoardMemberUseCase {
  final BoardMemberRepository repository;

  DeleteBoardMemberUseCase(this.repository);

  Future<void> call(String boardId, String userId) {
    return repository.removeBoardMember(boardId: boardId, userId: userId);
  }
}