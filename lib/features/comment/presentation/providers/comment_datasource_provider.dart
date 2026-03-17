import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/comment_remote_datasource.dart';
import '../../data/datasources/fake_comment_datasource.dart';
import '../../data/datasources/supabase_comment_datasource_impl.dart';

/// Provider for the Remote Data Source (Supabase)
final remoteCommentDataSourceProvider = Provider<CommentRemoteDataSource>((ref) {
  return SupabaseCommentDataSourceImpl();
});

/// Provider for the Local Data Source (FakeDB acts as Cache)
final localCommentDataSourceProvider = Provider<CommentRemoteDataSource>((ref) {
  final database = ref.watch(fakeDatabaseProvider);
  return FakeCommentDataSource(database);
});

/// Legacy provider for backward compatibility
final commentDataSourceProvider = Provider<CommentRemoteDataSource>((ref) {
  return ref.watch(remoteCommentDataSourceProvider);
});
