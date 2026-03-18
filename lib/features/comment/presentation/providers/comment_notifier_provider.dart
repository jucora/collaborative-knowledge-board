import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';
import 'comment_notifier.dart';

final commentNotifierProvider =
    AsyncNotifierProvider.family<CommentNotifier, List<Comment>, String>(
  CommentNotifier.new,
);
