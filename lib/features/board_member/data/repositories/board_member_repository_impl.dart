import 'package:collaborative_knowledge_board/features/board_member/domain/entities/board_member.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/board_member_repository.dart';

class BoardMemberRepositoryImpl extends BoardMemberRepository {

  @override
  Future<Either<Failure, void>> addMemberToBoard({
    required userId,
    required String boardId,
    required String role,
    required DateTime joinedAt,
  }) {
    // TODO: implement addMemberToBoard
    throw UnimplementedError();
  }

  @override
  Future<void> removeMemberFromBoard({
    required String boardId,
    required String userId
  }) {
    // TODO: implement removeMemberFromBoard
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<BoardMember>>> getBoardMembers(String boardId) {
    // TODO: implement getBoardMembers
    throw UnimplementedError();
  }
}