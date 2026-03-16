import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/board_member.dart';

abstract class BoardMemberRepository {
  Future<Either<Failure, List<BoardMember>>> getBoardMembers(String boardId);

  Future<Either<Failure, BoardMember>> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
    required DateTime joinedAt,
  });

  Future<Either<Failure, void>> removeBoardMember({
    required String boardId,
    required String userId,
  });
}
