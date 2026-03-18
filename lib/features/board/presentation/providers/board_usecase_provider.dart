import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_board_usecase.dart';
import '../../domain/usecases/delete_board_usecase.dart';
import '../../domain/usecases/get_boards_usecase.dart';
import 'board_repository_provider.dart';

final getBoardsUseCaseProvider = Provider<GetBoardsUseCase>((ref) {
  final repository = ref.read(getBoardRepositoryProvider);
  return GetBoardsUseCase(repository);
});

final createBoardUseCaseProvider = Provider<CreateBoardUseCase>((ref) {
  final repository = ref.read(getBoardRepositoryProvider);
  return CreateBoardUseCase(repository);
});

final deleteBoardUseCaseProvider = Provider<DeleteBoardUseCase>((ref) {
  final repository = ref.read(getBoardRepositoryProvider);
  return DeleteBoardUseCase(repository);
});
