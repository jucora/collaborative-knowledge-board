import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/board_member_remote_datasource.dart';
import '../../data/datasources/fake_board_member_datasource.dart';
import '../../data/datasources/supabase_board_member_datasource_impl.dart';

/// Provider for the Remote Data Source (Supabase)
final remoteBoardMemberDataSourceProvider = Provider<BoardMemberRemoteDataSource>((ref) {
  return SupabaseBoardMemberDataSourceImpl();
});

/// Provider for the Local Data Source (FakeDB acts as Cache)
final localBoardMemberDataSourceProvider = Provider<BoardMemberRemoteDataSource>((ref) {
  final database = ref.watch(fakeDatabaseProvider);
  return FakeBoardMemberDatasource(database);
});

/// Legacy provider for backward compatibility
final boardMemberDatasourceProvider = Provider<BoardMemberRemoteDataSource>((ref) {
  return ref.watch(remoteBoardMemberDataSourceProvider);
});
