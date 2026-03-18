import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../data/repositories/board_member_repository_impl.dart';
import '../../domain/repositories/board_member_repository.dart';
import 'board_member_datasource_provider.dart';

final boardMemberRepositoryProvider = Provider<BoardMemberRepository>((ref) {
  final remote = ref.watch(remoteBoardMemberDataSourceProvider);
  final local = ref.watch(localBoardMemberDataSourceProvider);
  final realTimeService = ref.watch(realTimeServiceProvider);

  return BoardMemberRepositoryImpl(
    remoteDataSource: remote,
    localCacheSource: local,
    simulatorService: realTimeService,
  );
});
