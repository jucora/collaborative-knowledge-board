import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../../../core/providers/config_provider.dart';
import '../../data/datasources/comment_remote_datasource.dart';
import '../../data/datasources/fake_comment_datasource.dart';
import '../../data/datasources/supabase_comment_datasource_impl.dart';

final commentDataSourceProvider = Provider<CommentRemoteDataSource>((ref) {
  if (useFakeData) {
    final database = ref.watch(fakeDatabaseProvider);
    return FakeCommentDataSource(database);
  }
  return SupabaseCommentDataSourceImpl();
});
