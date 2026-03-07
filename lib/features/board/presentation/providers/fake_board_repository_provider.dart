import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';
import '../../data/datasources/fake_board_datasource.dart';
import '../../data/repositories/fake_board_repository_impl.dart';
import '../../domain/repositories/board_repository.dart';

final getBoardRepositoryProvider =
Provider<BoardRepository>((ref) {

  final database = ref.watch(fakeDatabaseProvider);

  final datasource = FakeBoardDataSource(database);

  return FakeBoardRepositoryImpl(datasource);

});