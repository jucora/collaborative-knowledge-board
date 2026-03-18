import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../domain/repositories/comment_repository.dart';
import 'comment_datasource_provider.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final remote = ref.watch(remoteCommentDataSourceProvider);
  final local = ref.watch(localCommentDataSourceProvider);
  final realTimeService = ref.watch(realTimeServiceProvider);

  return CommentRepositoryImpl(
    remoteDataSource: remote,
    localCacheSource: local,
    simulatorService: realTimeService,
  );
});
