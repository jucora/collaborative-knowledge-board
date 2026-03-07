import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/fake_board_column_datasource.dart';
import '../../data/repositories/fake_board_column_repository_impl.dart';
import '../../domain/entities/board_column.dart';
import '../../domain/usecases/get_board_columns_usecase.dart';

final getBoardColumnsUseCaseProvider =
FutureProvider.family<List<BoardColumn>, String>((ref, boardId) async {

  final database = ref.watch(fakeDatabaseProvider);

  final datasource = FakeBoardColumnDatasource(database);

  final repository = FakeBoardColumnRepositoryImpl(datasource);

  final useCase = GetBoardColumnsUseCase(repository);

  final result = await useCase(boardId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (columns) => columns,
  );
});