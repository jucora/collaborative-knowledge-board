import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../../../core/providers/config_provider.dart';
import '../../data/datasources/board_remote_datasource.dart';
import '../../data/datasources/fake_board_datasource.dart';
import '../../data/datasources/supabase_board_datasource_impl.dart';

final boardDatasourceProvider = Provider<BoardRemoteDataSource>((ref) {
  if (useFakeData) {
    final database = ref.watch(fakeDatabaseProvider);
    return FakeBoardDataSource(database);
  }

  // Si useFakeBoard es false, devolvemos la implementación de Supabase
  return SupabaseBoardDataSourceImpl();
});