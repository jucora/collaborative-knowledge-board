import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:collaborative_knowledge_board/features/board_member/domain/entities/board_member.dart';
import 'package:collaborative_knowledge_board/features/board_member/domain/repositories/board_member_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../../../core/fake_data/fake_database.dart';

class FakeBoardMemberRepositoryImpl extends BoardMemberRepository{

  late final FakeDatabase _db;

  FakeBoardRepositoryImpl() {
    _db = FakeDataGenerator.generate();
  }

  @override
  Future<void> addMemberToBoard({
    required userId,
    required String boardId,
    required String role,
    required DateTime joinedAt
  }) async{

    try {
        await Future.delayed(const Duration(milliseconds: 300));

        final newMember = BoardMember(
          userId: userId,
          boardId: boardId,
          role: role,
          joinedAt: joinedAt,
        );

        _db.members.add(newMember);

      } catch (e) {
        throw ServerFailure('Failed to add member to board');
      }
  }

  @override
  Future<void> removeMemberFromBoard({
    required String boardId,
    required String userId
  }) async {
    try {
        await Future.delayed(const Duration(milliseconds: 300));

        _db.members.removeWhere((m) => m.boardId == boardId && m.userId == userId);

      } catch (e) {
        throw ServerFailure('Failed to remove member from board');
      }
  }

  @override
  Future<Either<Failure, List<BoardMember>>> getBoardMembers(
      String boardId) async{
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final members = _db.members.where((m) => m.boardId == boardId).toList();

      return Right(List.unmodifiable(members));
    } catch (e) {
      return Left(ServerFailure('Failed to load board members'));
    }
  }
}