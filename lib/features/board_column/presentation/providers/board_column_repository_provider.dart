import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../data/repositories/board_column_repository_impl.dart';
import '../../domain/repositories/board_column_repository.dart';
import 'board_column_datasource_provider.dart';

final boardColumnRepositoryProvider = Provider<BoardColumnRepository>((ref) {
  final remote = ref.watch(remoteBoardColumnDataSourceProvider);
  final local = ref.watch(localBoardColumnDataSourceProvider);
  final realTimeService = ref.watch(realTimeServiceProvider);

  return BoardColumnRepositoryImpl(
    remoteDataSource: remote,
    localCacheSource: local,
    simulatorService: realTimeService,
  );
});
