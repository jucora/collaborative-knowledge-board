import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:collaborative_knowledge_board/features/board_member/data/datasources/fake_board_member_datasource.dart';
import 'package:collaborative_knowledge_board/features/board_member/domain/entities/board_member.dart';
import 'package:collaborative_knowledge_board/features/board_member/domain/repositories/board_member_repository.dart';
import 'package:dartz/dartz.dart';

class FakeBoardMemberRepositoryImpl extends BoardMemberRepository{

  final FakeBoardMemberDatasource datasource;

  FakeBoardMemberRepositoryImpl(this.datasource);

  @override
  Future<void> addMemberToBoard({
    required userId,
    required String boardId,
    required String role,
    required DateTime joinedAt,
  }) async {

    try {

      await Future.delayed(const Duration(milliseconds: 300));

      final newMember = BoardMember(
        userId: userId,
        boardId: boardId,
        role: role,
        joinedAt: joinedAt,
      );

      await datasource.addMemberToBoard(newMember);

    } catch (e) {
      throw const ServerFailure('Failed to add member to board');
    }
  }

  @override
  Future<void> removeMemberFromBoard({
    required String boardId,
    required String userId
  }) async {
    try {
        await Future.delayed(const Duration(milliseconds: 300));

        await datasource.removeMemberFromBoard(boardId, userId);

      } catch (e) {
        throw const ServerFailure('Failed to remove member from board');
      }
  }

  @override
  Future<Either<Failure, List<BoardMember>>> getBoardMembers(
      String boardId) async{
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final boardMembers = await datasource.getBoardMembers(boardId);

      return Right(List.unmodifiable(boardMembers));
    } catch (e) {
      return const Left(ServerFailure('Failed to load board members'));
    }
  }
}