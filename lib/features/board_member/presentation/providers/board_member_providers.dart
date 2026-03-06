import 'package:collaborative_knowledge_board/features/board_member/domain/usecases/get_board_members_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/fake_board_member_repository_impl.dart';
import '../../domain/repositories/board_member_repository.dart';

// Repository Provider for Board Members
final boardMembersRepositoryProvider = Provider<BoardMemberRepository>((ref) {

  if (useFake) {
    return FakeBoardMemberRepositoryImpl();
  }

  return throw UnimplementedError(
    'Implement BoardMemberRepository when using a real API',
  );
});

// Get Board Members Use Case Provider
final getBoardMembersUseCaseProvider = Provider<GetBoardMembersUseCase>((ref) {
  final repository = ref.read(boardMembersRepositoryProvider);
  return GetBoardMembersUseCase(repository);
});