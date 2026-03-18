import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../data/repositories/board_repository_impl.dart';
import '../../domain/repositories/board_repository.dart';
import 'board_datasource_provider.dart';

final getBoardRepositoryProvider = Provider<BoardRepository>((ref) {
  final remote = ref.watch(remoteBoardDataSourceProvider);
  final local = ref.watch(localBoardDataSourceProvider);
  final realTimeService = ref.watch(realTimeServiceProvider);

  return BoardRepositoryImpl(
    remoteDataSource: remote,
    localCacheSource: local,
    simulatorService: realTimeService,
  );
});
