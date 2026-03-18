import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/board.dart';
import 'board_usecase_provider.dart';

/// Board Notifier Provider
final boardNotifierProvider =
FutureProvider<List<Board>>((ref) async {

  final useCase = ref.watch(getBoardsUseCaseProvider);

  final result = await useCase();

  return result.fold(
        (failure) => throw Exception(failure.message),
        (boards) => boards,
  );
});