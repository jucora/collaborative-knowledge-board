import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../domain/repositories/comment_repository.dart';
import 'comment_datasource_provider.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final datasource = ref.watch(commentDataSourceProvider);

  return CommentRepositoryImpl(datasource);
});
