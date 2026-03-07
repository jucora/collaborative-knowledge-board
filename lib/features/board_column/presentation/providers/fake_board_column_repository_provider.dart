import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/fake_board_column_datasource.dart';
import '../../data/repositories/fake_board_column_repository_impl.dart';
import '../../domain/repositories/board_column_repository.dart';

//Fake Board Column Repository Provider
final boardColumnRepositoryProvider =
Provider<BoardColumnRepository>((ref) {

  final database = ref.watch(fakeDatabaseProvider);

  final datasource = FakeBoardColumnDatasource(database);

  return FakeBoardColumnRepositoryImpl(datasource);

});