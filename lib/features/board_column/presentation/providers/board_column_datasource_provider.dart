import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/board_column_remote_datasource.dart';
import '../../data/datasources/fake_board_column_datasource.dart';
import '../../data/datasources/supabase_board_column_datasource_impl.dart';

/// Provider for the Remote Data Source (Supabase)
final remoteBoardColumnDataSourceProvider = Provider<BoardColumnRemoteDataSource>((ref) {
  return SupabaseBoardColumnDataSourceImpl();
});

/// Provider for the Local Data Source (FakeDB acts as Cache)
final localBoardColumnDataSourceProvider = Provider<BoardColumnRemoteDataSource>((ref) {
  final database = ref.watch(fakeDatabaseProvider);
  return FakeBoardColumnDatasource(database);
});

/// Legacy provider for backward compatibility
final boardColumnDatasourceProvider = Provider<BoardColumnRemoteDataSource>((ref) {
  return ref.watch(remoteBoardColumnDataSourceProvider);
});
