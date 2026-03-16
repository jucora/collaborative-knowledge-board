import 'package:collaborative_knowledge_board/features/board/presentation/providers/board_datasource_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/board_repository_impl.dart';
import '../../domain/repositories/board_repository.dart';

final getBoardRepositoryProvider = Provider<BoardRepository>((ref) {
  final datasource = ref.watch(boardDatasourceProvider);

  return BoardRepositoryImpl(datasource);
});