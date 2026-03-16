import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/fake_data/fake_database_provider.dart';
import '../../../../core/providers/config_provider.dart';
import '../../data/datasources/board_column_remote_datasource.dart';
import '../../data/datasources/fake_board_column_datasource.dart';
import '../../data/datasources/supabase_board_column_datasource_impl.dart';

/// Control flag to toggle between Fake and Supabase

final boardColumnDatasourceProvider = Provider<BoardColumnRemoteDataSource>((ref) {
  if (useFakeData) {
    final database = ref.watch(fakeDatabaseProvider);
    return FakeBoardColumnDatasource(database);
  }
  return SupabaseBoardColumnDataSourceImpl();
});
