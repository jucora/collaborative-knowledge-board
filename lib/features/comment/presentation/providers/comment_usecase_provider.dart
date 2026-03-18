import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import 'comment_repository_provider.dart';

final getCommentsUseCaseProvider =
Provider<GetCommentsUseCase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return GetCommentsUseCase(repository);
});


final addCommentUseCaseProvider =
Provider<AddCommentUseCase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return AddCommentUseCase(repository);
});