import 'package:collaborative_knowledge_board/features/board/domain/entities/board.dart';
import 'package:collaborative_knowledge_board/features/board/presentation/pages/board_dashboard_page.dart';
import 'package:collaborative_knowledge_board/features/board/presentation/providers/board_future_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard should show list of boards', (WidgetTester tester) async {
    // arrange
    final tBoards = [
      Board(
        id: '1',
        title: 'Board 1',
        description: 'Test Description 1',
        createdAt: DateTime.now(),
        ownerId: 'user_1',
        columns: [],
        members: [],
      ),
      Board(
        id: '2',
        title: 'Board 2',
        description: 'Test Description 2',
        createdAt: DateTime.now(),
        ownerId: 'user_1',
        columns: [],
        members: [],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the provider to return our test data
          boardNotifierProvider.overrideWith((ref) => tBoards),
        ],
        child: const MaterialApp(
          home: BoardDashboardPage(),
        ),
      ),
    );

    // Initial state might be loading if it was a real future, but with overrideWith it might be immediate.
    // Let's pump to be sure.
    await tester.pump();

    // assert
    expect(find.text('Board 1'), findsOneWidget);
    expect(find.text('Board 2'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsNWidgets(2));
  });
}
