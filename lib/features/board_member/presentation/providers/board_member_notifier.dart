import 'dart:async';
import 'package:collaborative_knowledge_board/features/board_member/domain/entities/board_member.dart';
import 'package:collaborative_knowledge_board/features/board_member/domain/usecases/get_board_members_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'board_member_providers.dart';

class BoardMemberNotifier extends FamilyAsyncNotifier<List<BoardMember>, String> {
  late final GetBoardMembersUseCase getBoardMembers;

  @override
  FutureOr<List<BoardMember>> build(String boardId) async{

    getBoardMembers = ref.read(getBoardMembersUseCaseProvider);
    final result = await getBoardMembers(boardId);

    return result.fold(
          (failure) => throw failure,
          (boardColumns) => boardColumns,
    );
  }}