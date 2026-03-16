import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/board_column_repository_impl.dart';
import '../../domain/repositories/board_column_repository.dart';
import 'board_column_datasource_provider.dart';

final boardColumnRepositoryProvider = Provider<BoardColumnRepository>((ref) {
  final datasource = ref.watch(boardColumnDatasourceProvider);

  return BoardColumnRepositoryImpl(datasource);
});