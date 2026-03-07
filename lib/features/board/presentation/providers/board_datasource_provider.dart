import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/fake_board_datasource.dart';

final boardDatasourceProvider =
Provider<FakeBoardDataSource>((ref) {

  final database = ref.watch(fakeDatabaseProvider);

  return FakeBoardDataSource(database);
});