import 'package:collaborative_knowledge_board/features/board_member/domain/entities/board_member.dart';
import 'package:collaborative_knowledge_board/features/board_member/domain/repositories/board_member_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class GetBoardMembersUseCase {
  final BoardMemberRepository repository;

  GetBoardMembersUseCase(this.repository);

  Future<Either<Failure, List<BoardMember>>> call(String boardId) {
    return repository.getBoardMembers(boardId);
  }
}