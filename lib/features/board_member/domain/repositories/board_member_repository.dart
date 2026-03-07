import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/board_member.dart';

abstract class BoardMemberRepository {

  Future<Either<Failure, List<BoardMember>>> getBoardMembers(String boardId);

  Future<void> addMemberToBoard({
    required userId,
    required String boardId,
    required String role,
    required DateTime joinedAt,
  });

  Future<void> removeMemberFromBoard({
    required String boardId,
    required String userId,
  });
}