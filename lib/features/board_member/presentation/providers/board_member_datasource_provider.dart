import 'package:collaborative_knowledge_board/features/board_member/data/datasources/fake_board_member_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/fake_data/fake_database_provider.dart';

final boardMemberDatasourceProvider =
Provider<FakeBoardMemberDatasource>((ref) {

  final database = ref.watch(fakeDatabaseProvider);

  return FakeBoardMemberDatasource(database);

});