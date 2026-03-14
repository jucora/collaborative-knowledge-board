import 'package:collaborative_knowledge_board/core/error/failures.dart';
import 'package:collaborative_knowledge_board/features/board/domain/entities/board.dart';
import 'package:collaborative_knowledge_board/features/board/domain/repositories/board_repository.dart';
import 'package:collaborative_knowledge_board/features/board/domain/usecases/get_boards_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBoardRepository extends Mock implements BoardRepository {}

void main() {
  late GetBoardsUseCase useCase;
  late MockBoardRepository mockBoardRepository;

  setUp(() {
    mockBoardRepository = MockBoardRepository();
    useCase = GetBoardsUseCase(mockBoardRepository);
  });

  final tBoards = [
    Board(
      id: '1',
      title: 'Test Board',
      description: 'Test Description',
      createdAt: DateTime.now(),
      ownerId: 'user_1',
      columns: [],
      members: [],
    ),
  ];

  test(
    'should get boards from the repository',
    () async {
      // arrange
      when(() => mockBoardRepository.getBoards())
          .thenAnswer((_) async => Right(tBoards));
      
      // act
      final result = await useCase();
      
      // assert
      expect(result, Right(tBoards));
      verify(() => mockBoardRepository.getBoards());
      verifyNoMoreInteractions(mockBoardRepository);
    },
  );

  test(
    'should return Failure when repository fails',
    () async {
      // arrange
      const tFailure = ServerFailure('Server Error');
      when(() => mockBoardRepository.getBoards())
          .thenAnswer((_) async => const Left(tFailure));
      
      // act
      final result = await useCase();
      
      // assert
      expect(result, const Left(tFailure));
      verify(() => mockBoardRepository.getBoards());
      verifyNoMoreInteractions(mockBoardRepository);
    },
  );
}
