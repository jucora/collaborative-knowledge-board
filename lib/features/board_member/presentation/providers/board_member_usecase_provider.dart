import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/add_board_member_usecase.dart';
import '../../domain/usecases/delete_board_member_usecase.dart';
import '../../domain/usecases/get_board_members_usecase.dart';
import 'board_member_repository_provider.dart';

final getBoardMembersUseCaseProvider =
Provider<GetBoardMembersUseCase>((ref) {

  final repository = ref.read(boardMemberRepositoryProvider);

  return GetBoardMembersUseCase(repository);

});

final addBoardMemberUseCaseProvider =
    Provider <AddBoardMemberUseCase>((ref) {
      final repository = ref.read(boardMemberRepositoryProvider);
    return AddBoardMemberUseCase(repository);
});

final deleteBoardMemberUseCaseProvider =
    Provider <DeleteBoardMemberUseCase>((ref) {
      final repository = ref.read(boardMemberRepositoryProvider);
    return DeleteBoardMemberUseCase(repository);
});