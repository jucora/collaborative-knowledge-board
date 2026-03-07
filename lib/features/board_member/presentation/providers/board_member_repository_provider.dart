import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/fake_board_member_repository_impl.dart';
import '../../domain/repositories/board_member_repository.dart';
import 'board_member_datasource_provider.dart';

final boardMembersRepositoryProvider = Provider<BoardMemberRepository>((ref) {
  final datasource = ref.watch(boardMemberDatasourceProvider);
  return FakeBoardMemberRepositoryImpl(datasource);
});