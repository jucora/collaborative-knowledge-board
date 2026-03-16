import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../../../core/providers/config_provider.dart';
import '../../data/datasources/board_member_remote_datasource.dart';
import '../../data/datasources/fake_board_member_datasource.dart';
import '../../data/datasources/supabase_board_member_datasource_impl.dart';

final boardMemberDatasourceProvider = Provider<BoardMemberRemoteDataSource>((ref) {
  if (useFakeData) {
    final database = ref.watch(fakeDatabaseProvider);
    return FakeBoardMemberDatasource(database);
  }
  return SupabaseBoardMemberDataSourceImpl();
});
