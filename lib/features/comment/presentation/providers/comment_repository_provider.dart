import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../card/presentation/providers/card_datasource_provider.dart';
import '../../data/repositories/fake_comment_repository_impl.dart';
import '../../domain/repositories/comment_repository.dart';
import 'comment_datasource_provider.dart';

final commentRepositoryProvider =
Provider<CommentRepository>((ref) {
  final datasource = ref.watch(cardDataSourceProvider);
  final commentDatasource = ref.watch(commentDataSourceProvider);
  return FakeCommentRepositoryImpl(datasource, commentDatasource);
});