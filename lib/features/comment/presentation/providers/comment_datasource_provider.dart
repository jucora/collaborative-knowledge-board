import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/fake_comment_datasource.dart';

final commentDataSourceProvider =
Provider<FakeCommentDataSource>((ref){
  final database = ref.watch(fakeDatabaseProvider);
  return FakeCommentDataSource(database);
});