import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board_column.dart';
import 'board_column_usecase_provider.dart';

final boardColumnsProvider =
FutureProvider.family<List<BoardColumn>, String>((ref, boardId) async {

  final useCase = ref.watch(getBoardColumnsUseCaseProvider);

  final result = await useCase(boardId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (columns) => columns,
  );
});