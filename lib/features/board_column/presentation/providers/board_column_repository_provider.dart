import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/fake_board_column_repository_impl.dart';
import 'board_column_datasource_provider.dart';

final boardColumnRepositoryProvider =
Provider((ref) {

  final datasource = ref.watch(boardColumnDatasourceProvider);

  return FakeBoardColumnRepositoryImpl(datasource);
});