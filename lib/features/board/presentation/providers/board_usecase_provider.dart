import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/delete_board_usecase.dart';
import '../../domain/usecases/get_boards_usecase.dart';
import 'board_repository_provider.dart';

// Get boards use case provider
final getBoardsUseCaseProvider =
Provider<GetBoardsUseCase>((ref) {
  final repository = ref.read(getBoardRepositoryProvider);
  return GetBoardsUseCase(repository);
});

// Delete board use case provider

final deleteBoardUseCaseProvider =
Provider<DeleteBoardUseCase>((ref) {
  final repository = ref.read(getBoardRepositoryProvider);
  return DeleteBoardUseCase(repository);
});