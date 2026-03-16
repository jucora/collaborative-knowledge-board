import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/board_member_repository_impl.dart';
import '../../domain/repositories/board_member_repository.dart';
import 'board_member_datasource_provider.dart';

final boardMemberRepositoryProvider = Provider<BoardMemberRepository>((ref) {
  final datasource = ref.watch(boardMemberDatasourceProvider);

  return BoardMemberRepositoryImpl(datasource);
});
