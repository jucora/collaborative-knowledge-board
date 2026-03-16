import 'package:dartz/dartz.dart';
import '../../../../core/error/exception_handler.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/board_member.dart';
import '../../domain/repositories/board_member_repository.dart';
import '../datasources/board_member_remote_datasource.dart';

class BoardMemberRepositoryImpl implements BoardMemberRepository {
  final BoardMemberRemoteDataSource remoteDataSource;

  BoardMemberRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<BoardMember>>> getBoardMembers(String boardId) async {
    try {
      final models = await remoteDataSource.getBoardMembers(boardId);
      return Right(models);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, BoardMember>> addBoardMember({
    required String boardId,
    required String userId,
    required String role,
    required DateTime joinedAt,
  }) async {
    try {
      final model = await remoteDataSource.addBoardMember(
        boardId: boardId,
        userId: userId,
        role: role,
      );
      return Right(model);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeBoardMember({
    required String boardId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.removeBoardMember(
        boardId: boardId,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ExceptionHandler.handle(e));
    }
  }
}
