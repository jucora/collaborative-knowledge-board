import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';
import 'comment_usecase_provider.dart';

final commentProvider =
FutureProvider.family<List<Comment>, String>((ref, cardId) async {

  final useCase = ref.watch(getCommentsUseCaseProvider);

  final result = await useCase(cardId);

  return result.fold(
        (failure) => throw Exception(failure.message),
        (comments) => comments);
});