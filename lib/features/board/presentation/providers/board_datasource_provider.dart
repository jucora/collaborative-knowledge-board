import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/board_remote_datasource.dart';
import '../../data/datasources/fake_board_datasource.dart';
import '../../data/datasources/supabase_board_datasource_impl.dart';

/// Provider for the Remote Data Source (Supabase)
final remoteBoardDataSourceProvider = Provider<BoardRemoteDataSource>((ref) {
  return SupabaseBoardDataSourceImpl();
});

/// Provider for the Local Data Source (FakeDB acts as Cache)
final localBoardDataSourceProvider = Provider<BoardRemoteDataSource>((ref) {
  final database = ref.watch(fakeDatabaseProvider);
  return FakeBoardDataSource(database);
});

/// Legacy provider for backward compatibility
final boardDatasourceProvider = Provider<BoardRemoteDataSource>((ref) {
  return ref.watch(remoteBoardDataSourceProvider);
});
