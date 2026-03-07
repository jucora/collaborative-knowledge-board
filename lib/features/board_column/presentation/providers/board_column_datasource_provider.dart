import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/fake_board_column_datasource.dart';

final boardColumnDatasourceProvider =
Provider<FakeBoardColumnDatasource>((ref) {

  final database = ref.watch(fakeDatabaseProvider);

  return FakeBoardColumnDatasource(database);
});