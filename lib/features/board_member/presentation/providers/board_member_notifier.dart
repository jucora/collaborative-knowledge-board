import 'dart:async';
import 'package:collaborative_knowledge_board/features/board_member/domain/entities/board_member.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_board_members_usecase.dart';
import 'board_member_usecase_provider.dart';

class BoardMemberNotifier extends FamilyAsyncNotifier<List<BoardMember>, String> {

  late final GetBoardMembersUseCase getBoardMembers;

  @override
  Future<List<BoardMember>> build(String boardId) async {

    getBoardMembers = ref.read(getBoardMembersUseCaseProvider);

    final result = await getBoardMembers(boardId);

    return result.fold(
          (failure) => throw failure,
          (boardMembers) => boardMembers,
    );
  }

  Future<void> refreshBoardMembers(String boardId) async {
    state = const AsyncLoading<List<BoardMember>>().copyWithPrevious(state);

    final result = await getBoardMembers(boardId);

    result.fold(
          (failure) => state = AsyncError(failure, StackTrace.current),
          (members) => state = AsyncData(members),
    );
  }

  Future<void> deleteBoardMember(
      String boardId,
      String userId,
      ) async {

    final deleteBoardMember = ref.read(deleteBoardMemberUseCaseProvider);

    await deleteBoardMember(boardId, userId);
  }
}