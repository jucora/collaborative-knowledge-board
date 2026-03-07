import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board_member.dart';
import 'board_member_usecase_provider.dart';

final boardMembersProvider =
FutureProvider.family<List<BoardMember>, String>((ref, boardId) async {

  final useCase = ref.watch(getBoardMembersUseCaseProvider);

  final result = await useCase(boardId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (members) => members,
  );
});