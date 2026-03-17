import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/real_time_service.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';
import 'card_datasource_provider.dart';

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final remote = ref.watch(remoteCardDataSourceProvider);
  final local = ref.watch(localCardDataSourceProvider);
  final realTimeService = ref.watch(realTimeServiceProvider);

  return CardRepositoryImpl(
    remoteDataSource: remote,
    localCacheSource: local,
    simulatorService: realTimeService,
  );
});
