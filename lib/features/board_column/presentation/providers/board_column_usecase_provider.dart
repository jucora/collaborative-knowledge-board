import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_board_column_usecase.dart';
import '../../domain/usecases/delete_board_column_usecase.dart';
import '../../domain/usecases/get_board_columns_usecase.dart';
import 'board_column_repository_provider.dart';

final getBoardColumnsUseCaseProvider = Provider<GetBoardColumnsUseCase>((ref) {
  final repository = ref.read(boardColumnRepositoryProvider);
  return GetBoardColumnsUseCase(repository);
});

final createBoardColumnUseCaseProvider = Provider<CreateBoardColumnUseCase>((ref) {
  final repository = ref.read(boardColumnRepositoryProvider);
  return CreateBoardColumnUseCase(repository);
});

final deleteBoardColumnProvider = Provider<DeleteBoardColumnUseCase>((ref) {
  final repository = ref.read(boardColumnRepositoryProvider);
  return DeleteBoardColumnUseCase(repository);
});
